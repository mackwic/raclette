require_relative 'utils/logger'

module Raclette
  module BaseOptions
    def BaseOptions.included(base)
      @@registered ||= {}
      @@registered[base] = {}

      class << base
        def options
          ## TODO
          #@@registered[base]
          {}
        end

        def set_option(key, value)
          # TODO
          #k = k.underscore
          #@@registered[base][key] = value
        end
      end
    end

    def load_options(opt)
      res = {}
      opt.each do |k,v|
        self.class.set_option k, v
        method = "options_#{k}"
        next unless v and respond_to? method
        if v == true
          send(method, res)
        else
          sends(method, v, res)
        end
      end
      res
    end

    def options_example(options)
      # this is how to add options to the scrapers
      # use it with super('name', {example: true}) in your scraper declaration
      options[:example] = true
    end

    def options_use_proxy(options)
      options[:httpstrategy] = :proxy
    end

    def self.load_global_options
      Logger.debug BaseOptions, 'Loading options'

      args = ENV.select {|k,_| /^RACLETTE_.+/.match k}.to_a
      args.map! do |k,v|
        k = k.downcase.parameterize.sub('raclette_', '')
        if v == 1 or v == '1'
          [k, true]
        else
          [k,v]
        end
      end
      Logger.debug BaseOptions, "Matching options: #{args}"

      CentralStorage.store('args', args) unless args.empty?
      args.each do |k,v|
        CentralStorage.store "arg_#{k}", v
        @@registered.each {|r,h| h[k] = v if h[k].nil?}
      end

      Logger.debug BaseOptions, 'END Loading options'
    end
  end
end
