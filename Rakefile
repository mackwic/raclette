require 'bundler/setup'
Bundler.require :default

require 'logger'
$logger = Logger.new 'system'

Dir.glob('./lib/**/*.rake').each do |rake|
  load "#{rake}"
end

# load app file
["./lib/**/*.rb"].each do |glob|
  Dir.glob(glob).each do |file|
    $logger.debug "[SYSTEM] loading #{file}..." if require file
  end
end
