require 'gametracker'

set :root, File.dirname(__FILE__)

if ENV['RACK_ENV'] != 'production'
  log = File.new("sinatra.log", "a+")
  $stdout.reopen(log)
  $stderr.reopen(log)
end

run GameTracker
