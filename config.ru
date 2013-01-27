require 'rack/ssl-enforcer'
require 'app'

use Rack::SslEnforcer, :only_hosts => 'bugsplat.info'
use Rack::ShowExceptions
run App.new
