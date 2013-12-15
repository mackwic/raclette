require './lib/utils/atomic_id'
module Raclette
  class Logger
    @@counter = AtomicId.new
    @@padding = 'SYSTEM'.size

    def initialize(name='SYSTEM')
      @id = @@counter.get
      @name = name
      @@padding = [@@padding, @name.size].max
      @stacked_name = ''

      @logger = ::Logger.new MultiIO.new(
        File.open("log/raclette_#{@name.parameterize}.log", "w"),
        STDOUT)
      @logger.formatter = proc {|*args| format(*args)}
      delegate_to_logger :debug, :info, :warn, :error, :fatal, :unknown
    end

    def format(severity, time, name, msg)
      name ||= 'SYSTEM'
      padding_l = (@@padding - name.size) / 2
      padding_r = padding_l + (name.size % 2)
      severity = ' ' + severity if severity == 'INFO' or severity == 'WARN'
      severity = '  ' + severity if severity == 'ANY'
      " #{severity}[#{@id}][#{' ' * padding_l}#{name}#{' ' * padding_r}]#{msg}\n"
    end

    def method_missing(name, *args)
      @stacked_name += "[#{name.to_s.parameterize}]"
      self
    end

    private
    def delegate_to_logger(*methods)
      methods.each do |m|
        body = proc do |args|
          args.prepend @stacked_name
          @logger.send m, @name do args end
          @stacked_name = ''
        end
        define_singleton_method m.to_s, body
        define_singleton_method 's' + m.to_s, lambda { |args| @logger.send m do args end }
      end
    end
  end
end
