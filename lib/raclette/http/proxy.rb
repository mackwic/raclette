module Raclette
  module HTTP
    class Proxy
      def initialize(logger)
        @logger = logger.with name: 'proxy'
        Logger.debug self, 'USE PROXIES'
      end

      def change_proxy(opt={})
        agent = opt[:agent] if opt[:agent]
        agent.shutdown
        proxy = opt[:proxy] if opt[:proxy]
        proxy ||= @proxie.good if opt[:a_good_one]
        proxy ||= @proxies.sample

        agent.set_proxy proxy['ip'], proxy['port']
        agent.anonymize
        @logger.info "Changed proxy to #{proxy}"
      end

      def get address, options={}
        change_proxy
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
          @logger.warn "Error during page loading. Testing proxy... (#{e})"
          begin
            @proxies.change_note proxy, -2
            agent.get 'http://example.com/'
            @logger.error "#{e.message} - IP: #{proxy[0]} (Proxy is good)"
          rescue => e
            @proxies.change_note proxy, -3
            @logger.error "Bad proxy, changing proxy (#{proxy}) (#{e.message})"
            @logger.error e.backtrace
          end
          change_proxy agent
          retry
        end
      end

      def proxies
        @@proxies ||= ProxyList.new
      end

      def agent
        @agent ||= Agent.new @logger.with name: 'http'
      end
    end
  end
end
