require 'thread'
require_relative 'logger'

module Raclette
  class CentralStorage
    def self.store(key, value)
      Logger.debug self, "STORE {#{key} => #{value}}"
      sync {|store| store[key] = value}
    end

    def self.retrieve(key)
      res = nil
      sync {|store| res = store[key]}
      Logger.debug self, "RETREIVE {#{key} => #{res}}"
      res
    end

    class << self
      alias :[]= :store
      alias :[] :retrieve
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
