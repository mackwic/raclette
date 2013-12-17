require 'minitest/spec'
require 'minitest/autorun'

Bundler.require :default, :test
Dir.glob('./lib/**/*.rb').each {|f| require f}

class VoidObject
  def method_missing(name, *args)
    self
  end
end

# from https://gist.github.com/tkareine/739662
class CountDownLatch
  attr_reader :count
   
  def initialize(to)
    require 'thread'
    @count = to.to_i
    raise ArgumentError, "cannot count down from negative integer" unless @count >= 0
    @lock = Mutex.new
    @condition = ConditionVariable.new
  end
   
  def count_down
    @lock.synchronize do
      @count -= 1 if @count > 0
      @condition.broadcast if @count == 0
    end
  end
   
  def wait
    @lock.synchronize do
      @condition.wait(@lock) while @count > 0
    end
  end
end

include Raclette

