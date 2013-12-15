require 'thread'

module Raclette
  class CentralStorage
    def self.store(key, value)
      sync {|store| store[key] = value}
    end

    def self.reteive(key)
      res = nil
      sync {|store| res = store[key]}
      res
    end

    private
    def self.me
      @@me ||= CentralStorage.new
    end

    def self.sync
      me.mutex.synchronize {yield me.data}
    end

    attr_reader :mutex, :data

    def initialize
      @mutex = Mutex.new
      @data = {}
    end
  end
end
