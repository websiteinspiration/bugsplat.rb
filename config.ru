require 'dotenv'
Dotenv.load

require './app'
require "rack/funky-cache"

use Rack::ShowExceptions

#if ENV['RACK_ENV'] == production
  use Rack::FunkyCache, file_types: [%r{text/(html|plain)}, %r{application/(pdf|atom|xml)}]
#end

run App.new
