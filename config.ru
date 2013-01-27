require 'rack/ssl-enforcer'
require 'app'

use Rack::SslEnforcer, :except_hosts => 'localhost:9393', :strict => true
use Rack::ShowExceptions
run App.new
