require 'thread'
require 'thread/pool'
require_relative 'utils/logger'

module Raclette
  class Scheduler

    def self.plan(&task)
      me.queue << task.curry
    end

    def self.shutdown
      Logger.debug self, 'No new tasks, waiting the pool to finish before shutdown...'
      me.pool.wait_done
      me.pool.shutdown
      me.queue << 'exit'
      Logger.debug self, 'END shutdown'
    end

    def self.shutdown!
      Logger.debug self, 'Shutdown NOW !'
      me.pool.shutdown!
      me.queue << 'exit'
      Logger.debug self, 'Shutdown DONE'
    end

    def self.me
      @@_self ||= Scheduler.new
    end

    # Mainly for testing purpose
    def self.flush
      Logger.debug self, 'flushing queue...'
      while me.queue.length > 0
        me.queue.pop.call(me.queue)
      end
      Logger.debug self, 'END flushing queue'
    end

    attr_reader :pool, :queue

    private
    def initialize(queue = nil, pool = nil)
      Logger.debug self, 'Init scheduler...'
      @queue = (queue || Queue.new)

      # in test env, we want to use Scheduler.flush to process tasks
      #return if ENV['ENV'] == 'test'

      nb = (ENV['DEBUG'].nil?) ? 1 : 100
      @pool = (pool || Thread.pool(nb))
      Thread.new @queue do |queue|
        Logger.debug self, 'Running main loop'
        loop do
          task = queue.pop
          Logger.debug self, "Got task #{task}"
          break if task == 'exit'

          @pool.process(task, queue) do |t, q|
            begin
              t.call(q)
            rescue => e
              puts e.message
              puts e.backtrace
            end
          end
        end
      end
    end
  end
end
