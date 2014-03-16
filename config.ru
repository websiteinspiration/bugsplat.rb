require 'dotenv'
Dotenv.load

require 'app'
require 'split/dashboard'
require 'grack'

Split::Dashboard.use Rack::Auth::Basic do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

grack_config = {
  project_root: ENV['PROJECTS_REPOS_ROOT'],
  adapter: Grack::GitAdapter,
  git_path: ENV['GIT_BINARY'],
  upload_pack: true
}

puts grack_config.to_json

use Rack::ShowExceptions
run Rack::URLMap.new \
  '/'       => App.new,
  '/source' => Grack::App.new(grack_config),
  '/split'  => Split::Dashboard.new
