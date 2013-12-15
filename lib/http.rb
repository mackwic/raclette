module Raclette
  module HTTP

    #include HTTPRaclette::Agent

    def HTTP.included(mod)
      ##TODO
      #include HTTPRaclette::Proxy if self.options[:proxy]
      #include HTTPRaclette::Tor if self.options[:tor]

      # if none of our modules have replaced the page get, 
      unless respond_to? :get_page
        self.class.send :define_method, :get, proc {|url, options={}| agent.get url}
      end
    end

    def agent
      @agent ||= Agent.new(logger.http)
    end
  end
end
