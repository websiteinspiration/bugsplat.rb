require 'dotenv'
Dotenv.load

require './app'
require "rack/funky-cache"

use Rack::ShowExceptions
use Rack::FunkyCache
run App.new
