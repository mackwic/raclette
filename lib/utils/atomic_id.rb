require 'thread'

module Raclette
  class AtomicId

    def initialize(base=0)
      @count = base
      @mutex = Mutex.new
    end

    def incr
      res = 0
      @mutex.synchronize do
        res = @count += 1
      end
      res
    end

    def self.global
      @@global ||= AtomicId.new
    end

    alias :get :incr

    #def a_incr
    #  return false unless @mutex.try_lock
    #  res = @count += 1
    #  @mutex.unlock
    #  res
    #end

    #alias :a_get :a_incr
  end
end
