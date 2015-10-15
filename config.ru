require 'dotenv'
Dotenv.load

require './app'
require "rack/funky-cache"

use Rack::ShowExceptions

if ENV['RACK_ENV'] == 'production'
  use Rack::FunkyCache,
    file_types: [%r{text/(html|plain)}, %r{application/(atom|xml)}],
    should_cache: ->(request, response) { request.path != '/handle-your-business' }
end

run App.new
