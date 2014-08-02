require 'dotenv'
Dotenv.load

require './app'
require "rack/funky-cache"

use Rack::ShowExceptions
use Rack::FunkyCache if ENV['RACK_ENV'] == 'production'
run App.new
