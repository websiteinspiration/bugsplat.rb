require 'dotenv'
Dotenv.load

require './app'
require "rack/funky-cache"

use Rack::ShowExceptions

use Rack::FunkyCache,
    file_types: [%r{text/(html|plain)}, %r{application/(atom|xml)}],
    should_cache: ->(req,res) { ENV['RACK_ENV'] == 'production' && req.path != '/handle-your-business' }

run App.new
