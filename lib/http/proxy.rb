module Raclette
  module HTTP
    module Proxy
      def Proxy.included(mod)
        @included ||= {}
        raise "Can't use both Proxies and Tor, choose one !" if @included[:tor]
        @included[:proxy] = true
      end

      def change_proxy(opt={})
        agent = opt[:agent] if opt[:agent]
        agent.shutdown
        proxy = opt[:proxy] if opt[:proxy]
        proxy ||= @proxie.good if opt[:a_good_one]
        proxy ||= @proxies.sample

        agent.set_proxy proxy['ip'], proxy['port']
        agent.anonymize
        logger.proxy.info "Changed proxy to #{proxy}"
      end

      def get address, options={}
        domain = Domainatrix.parse(address).domain

        begin
          proxy = agent.proxy
          agent.get address
          raise "This proxy is blacklisted" if url(agent.page).match 'captcha'
          raise "This proxy redirected to a non-wanted page" if domain != Domainatrix.parse(url(agent.page)).domain
          raise "This proxy returns 200 with blank page" if options[:expect] and agent.page.at(options[:expect]).nil?
          @proxies.change_note proxy, 1
          @forbidden = 0
        rescue => e
          logger.http.warn "Error during page loading. Testing proxy... (#{e})"
          begin
            @proxies.change_note proxy, -2
            agent.get 'http://example.com/'
            logger.http.error "#{e.message} - IP: #{proxy[0]} (Proxy is good)"
          rescue => e
            @proxies.change_note proxy, -3
            logger.http.error "Bad proxy, changing proxy (#{proxy}) (#{e.message})"
            logger.http.error e.backtrace
          end
          change_proxy agent
          retry
        end
      end

      def change_proxy agent, options = {}
        agent.shutdown
        @forbidden = 0
        if options[:a_good_one]
          proxy = @proxies.good
        else
          proxy = @proxies.sample
        end
        #@mutex.synchronize do
        #  agent.set_proxy proxy['ip'], proxy['port']
        #end
        agent.set_proxy proxy
        agent.anonymize
        logger.http.info "Changed Proxy to #{proxy}"
      end

      def proxies
        @@proxies ||= ProxyList.new
      end
    end

    module Tor
      def Tor.included(mod)
        @included ||= {}
        raise "Can't use both Proxies and Tor, choose one !" if @included[:proxy]
        @included[:tor] = true

        logger.tor.debug "Loading tor..."

        ENV['TOR_BIN'] ||= 'tor'
        unless File.exist? ENV['TOR_BIN']
          @logger.fatal 'No tor executable found ! Set your TOR_BIN variable correctly'
          exit 1
        end
        spawn ENV['TOR_BIN']

        logger.tor.debug "Tor launched, waiting a bit..."

        sleep 4.seconds
        require 'socksify'
        ENV['TOR_PORT'] ||= "9050"
        TCPSocket::socks_server = '127.0.0.1'
        TCPSocket::socks_port = ENV['TOR_PORT']

        logger.tor.debug "OK, global proxy set"
      end
    end
  end
end
