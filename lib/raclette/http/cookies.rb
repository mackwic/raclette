module Raclette
  module HTTP
    module Cookies
      def Cookies.included(mod)
        agent.pre_connect_hooks << proc do |agent, connexionID|
          agent.cookie_jar = CentralStorage.retrieve connexionID + 'Cookies'
          logger.cookies.debug "Retrieved cookies: #{agent.cookie_jar}"
        end

        agent.post_connect_hooks << proc do |agent, connexionID|
          CentralStorage.store connexionID + 'Cookies', agent.cookie_jar
          logger.cookies.debug "Stored cookies: #{agent.cookie_jar}"
        end
      end
    end
  end
end
