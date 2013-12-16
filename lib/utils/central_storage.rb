require 'thread'

module Raclette
  class CentralStorage
    def self.store(key, value)
      sync {|store| store[key] = value}
    end

    def self.retreive(key)
      res = nil
      sync {|store| res = store[key]}
      res
    end

    attr_reader :mutex, :data

    private
    def self.me
      @@me ||= CentralStorage.new
    end

    def self.sync
      me.mutex.synchronize {yield me.data}
    end

    def initialize
      @mutex = Mutex.new
      @data = {}
    end
  end
end
