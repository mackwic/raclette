require './lib/utils/atomic_id'
module Raclette
  module HTTP
 
    class Agent
      # TODO handle that with config file
      @@ua_list = JSON.load(File.open 'db/ua_list.json')
      TIMEOUT = 5

      attr_reader :proxy

      def initialize(logger)
        @id = AtomicId::global.get
        @agent = Mechanize.new do |a|
          a.user_agent = @@ua_list.sample
          a.follow_meta_refresh = true
          a.redirect_ok = :all
          a.robots = false
          a.log = logger
          a.history.max_size = 1
          a.read_timeout = TIMEOUT
          a.open_timeout = TIMEOUT
          a.idle_timeout = TIMEOUT
          a.keep_alive_time = TIMEOUT
          yield a if block_given?
        end
      end

      def anonymize
        @agent.cookie_jar.clear!
        @agent.user_agent = UA_LIST.sample
      end

      def set_proxy(ip, port)
        @proxy = [ip, port]
        @agent.set_proxy ip, port
      end

      def get(*args)
        # TODO handle ConnexionID
        @agent.get(*args)
      end

      def method_missing(m, *args, &block)
        @agent.send(m, *args, &block)
      end

      def self.with_new(options)
        Agent.new do |agent|
          if respond_to? :change_proxy
            options[:agent] = agent
            change_proxy options
          end
          yield agent
        end
      end
    end
  end
end
