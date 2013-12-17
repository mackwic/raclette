module Raclette
  module BaseOptions
    def BaseOptions.included(base)
      class << base
        def options
          {} #TODO
        end
      end
    end

    def load_options(opt)
      opt.each do |k,v|
        method = "options_#{k}"
        next unless v and respond_to? method
        if v == true
          send method
        else
          send method, v
        end
      end
    end

    def options_example
      # this is how to add options to the scrapers
      # use it with super('name', {example: true}) in your scraper declaration
    end
  end
end
