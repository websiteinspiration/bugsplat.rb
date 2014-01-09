require 'dotenv'
Dotenv.load

require 'app'
require 'split/dashboard'

Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

use Rack::ShowExceptions
run Rack::URLMap.new \
  '/'      => App.new,
  '/split' => Split::Dashboard.new
