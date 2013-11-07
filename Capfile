require 'rubygems'
require 'capistrano-buildpack'

set :application, "bugsplatdotinfo-pkdc"
set :repository, "git@git.bugsplat.info:peter/bugsplat.git"
set :scm, :git
set :additional_domains, %w(
  www.petekeen.net
  petekeen.net
  bugsplat.info
  www.bugsplat.info
  www.petekeen.com
  petekeen.com
  peterkeen.com
  www.peterkeen.com
  petekeen.org
  www.petekeen.org
  pkn.me
)

role :web, "web01.bugsplat.info"
set :use_ssl, true
set :ssl_cert_path, '/etc/nginx/certs/www.petekeen.net.crt'
set :ssl_key_path, '/etc/nginx/certs/www.petekeen.net.key'

set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 6700
set :concurrency, "web=1"

read_env 'prod'

load 'deploy'
