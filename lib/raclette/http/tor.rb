module Raclette
  module HTTP
    class Tor
      def initialize(logger)
        Logger.debug self, "Loading tor..."

        ENV['TOR_BIN'] ||= 'tor'
        unless File.exist? ENV['TOR_BIN']
          @logger.fatal 'No tor executable found ! Set your TOR_BIN variable correctly'
          exit 1
        end
        spawn ENV['TOR_BIN']

        Logger.debug self, "Tor launched, waiting a bit..."

        sleep 4.seconds
        require 'socksify'
        ENV['TOR_PORT'] ||= "9050"
        TCPSocket::socks_server = '127.0.0.1'
        TCPSocket::socks_port = ENV['TOR_PORT']

        Logger.debug self, "OK, global proxy set. Can use standard HTTP transparently..."

        @http = Direct.new(logger)
      end

      def get url, opt={}
        @http.get url
      end
    end
  end
end
