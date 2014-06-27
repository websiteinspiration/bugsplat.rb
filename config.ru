require 'dotenv'
Dotenv.load

require './app'

use Rack::ShowExceptions
run App.new
