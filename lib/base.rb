require './lib/utils/atomic_id'
require './lib/utils/logger'
require './lib/utils/rakelette'
require './lib/utils/central_storage'
require './lib/scheduler'
require './lib/http'

module Raclette
  class Base
    include BaseOptions

    @@id = AtomicId.global.incr

    attr_reader :logger

    def initialize(name, opt = {})
      @logger = Logger.new name
      self.class.send :include, HTTP

      load_options opt
    end

    def self.produce(klass, opt)
      # TODO try to emulate the strong parameters if can't make them work
      #params = ::ActionController::Parameters.new(opt)
      #params.require(:on, :aggregate).permit(:total, :action, :pipe)
      options = {
        action: :aggregate,
      }
      options.merge! opt

      # args we'll ask in the rake task, and interpolate with url later
      interpol_args = options[:on].scan(/@{(.+?)}/).flatten
      # page and offset counters are always provided automatically
      interpol_args.delete_if {|a| a == 'page_counter' or a == 'offset_counter'}

      producer_job = Proc.new do |action, aggregate, url, agent, args, res_queue|
        # replace placeholders in url by lately binded arguments
        args.each {|k,v| url.sub!('@{' + k.to_s + '}', v.to_s)}

        agent.get url
        res = agent.page.search(aggregate)
        args[:offset_counter] += res.length
        args[:page_counter] += 1

        case action
        when :aggregate then Scheduler.plan do |q| call_consumer res end
        when :follow_link then
          res.map {|l| l['href']}.each do |l|
            Scheduler.plan do |q|
              agent.get l
              q << proc {call_consumer agent.page}
            end
          end
        end
      end
      # inject all the params we already know in the proc args
      producer_job = producer_job.curry[options[:action], options[:aggregate], options[:on]]

      Rakelette.register_scraper klass, interpol_args, producer_job
    end

    def self.consume(klass, *consumers)
      if consumers.length == 0
        raise ArgumentError.new 'Consume needs at least one method symbol !'
      end
      unless klass.kind_of? Class
        raise "Your Raclette instance didn't provide self as first argument !"
      end
      unless consumers.first.kind_of? Symbol
        raise "Your Raclette instance didn't defined its static consume method !"
      end

      # unroll consumers into one normalized proc
      res = nil
      if consumers.length == 1
        res = proc {|arg| klass.send "consume_#{name}", arg}
      else
        res = proc do |klass, consumers, arg|
          pipe = Pipeout.new
          consumers.each_with_index do |c,i|
            if i == 0 
              pipe[c] = klass.send "consume_#{c}", arg
            else
              pipe[c] = klass.send "consume_#{c}", arg, pipe
            end
          end
        end
        res = res.curry[klass, consumers]
      end

      CentralStorage.store consumer_name, res
    end
    ################
    private
    #################

    def consumer_name
      @consumer_name ||= "#{self.class.to_s.parameterize}Consumer"
    end

    def data_class_name
      @data_class_name ||= self.class.to_s.gsub(/\w+::/, '')
    end

    def data_class
      # data class is the same name, but in the global namespace
      @data_class ||= Object.const_get data_class_name
    end

    def call_consumer(*args)
      consumer = CentralStorage.retreive consumer_name
      data = consumer.call(*args)

      # we probably need to create the data model which goes with it
      if data_class.present?
        @data_class = Class.new(ActiveRecord::Base)
        @data_class.has_and_belongs_to_many :something # TODO
      end
      # TODO: check that data is compatible with the model
      @data_class.find_or_create data unless options['no_save_data']
    end
  end
end
