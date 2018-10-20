require 'rubygems'
require 'capistrano-buildpack'

set :application, "bugsplatdotinfo-pkdc"
set :repository, "git@github.com:peterkeen/bugsplat.rb.git"
set :scm, :git
set :buildpack_url, "git@git.zrail.net:peter/bugsplat-buildpack-ruby-shared"

set :user, "peter"

set :concurrency, "web=1"

load 'deploy'

role :web, "kodos.zrail.net"
set :base_port, 6700
set :use_ssl, true
set :force_ssl, true
set :listen_address, '10.248.9.84'

set :ssl_cert_path, '/etc/nginx/certificates/site-6/fullchain.pem'
set :ssl_key_path, '/etc/nginx/certificates/site-6/privkey.pem'

set :foreman_export_path, "/lib/systemd/system"
set :foreman_export_type, "systemd"  

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

read_env 'prod'
