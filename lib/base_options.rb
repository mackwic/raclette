module Raclette
  module BaseOptions
    def BaseOptions.included(base)
      class << base
        def options
          {} #TODO
        end
      end
    end
  end
end
