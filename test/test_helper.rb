Bundler.require :default, :test
Dir.glob('./lib/**/*.rb').each {|f| require f}

#intialize minitest and coveralls
require 'minitest/autorun'
require 'coveralls'
Coveralls.wear!


