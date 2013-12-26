require_relative './http/agent.rb'
require_relative './http/proxy.rb'
require_relative './http/cookies.rb'
require_relative './http/tor.rb'

module Raclette
  module HTTP
    class Direct
      def initialize(logger)
        @logger = logger.with name: 'http'
        Logger.debug self, 'USE STANDARD GET'
      end

      def get url, opt={}
        agent.get url
      end

      def agent
        @agent ||= Agent.new(@logger)
      end
    end
  end
end
