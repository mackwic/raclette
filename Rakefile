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


require 'rake/testtask'

Rake::TestTask.new do |t|
  ENV['ENV'] = 'test'
  require 'simplecov'
  SimpleCov.start do
    command_name 'minitest'
  end
  require 'coveralls'

  t.libs.push "lib"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

task :default => :test
