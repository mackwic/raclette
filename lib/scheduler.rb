require 'thread/pool'

module Raclette
  class Scheduler

    def self.plan(&task)
      task = task.curry[me.queue]
      me.queue << task
    end

    def shutdown
      queue << 'exit'
      me.pool.shutdown
    end

    def self.me
      @@self ||= Scheduler.new
    end

    attr_reader :queue

    private
    def initialize
      @queue = Queue.new
      @pool = Thread.pool(100)
      Thread.new do
        task = @queue.pop
        return if task == 'exit'
        pool.process(&task)
      end
    end
  end
end
