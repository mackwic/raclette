module Raclette
  # This is just an handy class to do:
  #     a, b, c = pipeout[:key1, :key2, :key3]
  class Pipeout
    def initialize
      @storage = {}
    end

    def []=(name, value)
      @storage[name] = value
    end

    def [](*args)
      res = []
      args.each {|a| res.push @storage[a]}
      res
    end
  end
end
