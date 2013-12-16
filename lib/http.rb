module Raclette
  module HTTP
    def HTTP.included(mod)
      include HTTPRaclette::Proxy if mod.send(:options)[:proxy]
      include HTTPRaclette::Tor if mod.send(:options)[:tor]

      unless respond_to? :get
        mod.send :define_method, :get, proc {|url, options={}| agent.get url}
      end
    end

    def agent
      @agent ||= Agent.new(logger.http)
    end
  end
end
