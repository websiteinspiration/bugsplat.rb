require 'rubygems'
require 'capistrano-buildpack'

set :application, "bugsplatdotinfo-pkdc"
set :repository, "git@git.zrail.net:peter/bugsplat.git"
set :scm, :git
set :buildpack_url, "git@git.zrail.net:peter/bugsplat-buildpack-ruby-shared"

set :user, "peter"

set :concurrency, "web=1"

load 'deploy'

task :stage do
  role :web, 'subspace.zrail.net'
  set :base_port, 8300
  set :additional_domains, %w(
    stage.petekeen.net
  )
  read_env 'stage'
end

task :prod do
  role :web, "web02.zrail.net"
  set :base_port, 6700
  set :use_ssl, true
  set :force_ssl, true
  set :ssl_cert_path, '/etc/nginx/certs/www.petekeen.net.crt'
  set :ssl_key_path, '/etc/nginx/certs/www.petekeen.net.key'

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
end
