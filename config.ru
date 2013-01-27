require 'rack/ssl'
require 'app'

use Rack::SSL
use Rack::ShowExceptions
run App.new
