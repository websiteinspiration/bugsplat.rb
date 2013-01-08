require 'rubygems'

set :application, "bugsplatdotinfo"
set :repository, "git@git.bugsplat.info:peter/bugsplat.git"
set :scm, :git
set :additional_domains, ['bugsplat.info']

role :web, "empoknor.bugsplat.info"
set :buildpack_url, "git@git.bugsplat.info:peter/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 6700
set :concurrency, "web=1"

read_env 'prod'

load 'deploy'
require 'capistrano-buildpack'


