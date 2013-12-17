module Raclette
  module BaseOptions
    def BaseOptions.included(base)
      @@registered ||= {}
      @@registered[base] = {}

      class << base
        def options
          @@registered[base]
        end

        def set_option(key, value)
          k = k.underscore
          @@registered[base][key] = value
        end
      end
    end

    def load_options(opt)
      opt.each do |k,v|
        self.class.set_option k, v
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

    def self.load_global_options
      args = ARGV.keep_if {|a| a.match?(/^--\w+/)}
      CentralStorage.store('args', args) unless args.empty?
      args.each do |a|
        a = a.underscore
        CentralStorage.store "arg_#{a}", true
        @@registered.each {|r| r[a] = true if r[a].nil?}
      end


      ARGV.delete args # unless Rake will fail
    end
  end
end
