require 'rubygems'
require 'capistrano-buildpack'

set :application, "bugsplatdotinfo-pkdc"
set :repository, "git@git.bugsplat.info:peter/bugsplat.git"
set :scm, :git
set :additional_domains, %w(
  www.petekeen.net
  petekeen.net
  bugsplat.info
  www.petekeen.com
  petekeen.com
  peterkeen.com
  www.peterkeen.com
  petekeen.org
  www.petekeen.org
  pkn.me
)

role :web, "empoknor.bugsplat.info"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 6700
set :concurrency, "web=1"

set :use_ssl, true
set :ssl_cert_path, '/etc/nginx/certs/www.petekeen.net.crt'
set :ssl_key_path, '/etc/nginx/certs/www.petekeen.net.key'

set :force_domain, 'www.petekeen.net'

read_env 'prod'

load 'deploy'
