require 'app'
require 'rack/force_domain'
use Rack::ShowExceptions
run App.new
