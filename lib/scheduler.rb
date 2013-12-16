require 'thread'
require 'thread/pool'

module Raclette
  class Scheduler

    def self.plan(&task)
      me.queue << task.curry
    end

    if ENV['ENV'] == 'test'
      def self.shutdown
        me.queue << 'exit'
        me.pool.shutdown
      end
    else
      def self.shutdown
        flush
      end
    end

    def self.me
      @@_self ||= Scheduler.new
    end

    if ENV['ENV'] == 'test'
      def self.flush
        while me.queue.length > 0
          me.queue.pop.call(me.queue)
        end
      end
    end

    attr_reader :pool, :queue

    private
    def initialize
      @queue = Queue.new

      # in test env, we want to use Scheduler.flush to process tasks
      return if ENV['ENV'] == 'test'

      @pool = Thread.pool(100)
      Thread.new @queue do |queue|
        loop do
          task = queue.pop
          break if task == 'exit'

          @pool.process(task, queue) do |t, q|
            begin
              t.call(q)
            rescue => e
              puts e.message
              p e.backtrace
            end
          end
        end
      end
    end
  end
end
