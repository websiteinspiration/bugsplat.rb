---
title: Deploy 12-Factor Apps with Capistrano::Buildpack
date: '2012-12-30 12:04:31'
id: 90b36
tags: Programming, Heroku
topic: Software
description: "Capistrano::Buildpack is a gem for deploying apps originally meant for Heroku onto your own hardware."
---

[prev]: /deploying-a-12-factor-app-with-capistrano
[12-factor]: http://www.12factor.net/
[capistrano-buildpack]: https://github.com/peterkeen/capistrano-buildpack
[foreman]: http://ddollar.github.com/foreman/
[foreman-export-nginx]: https://github.com/peterkeen/foreman-export-nginx

Last month I wrote a [short article][prev] describing a method of deploying a [12-factor application][12-factor] application to your own hardware or VPS, outside of Heroku. Today I'm happy to announce a gem named [capistrano-buildpack][] which packages up and formalizes this deployment method.

--fold--

Basically, all this does is wrap up the `before` and `after` hooks that the other article talks about, which lets you set up a Capfile that looks like this:

```ruby
require 'rubygems'

set :application, "bugsplatdotinfo"
set :repository, "https://github.com/peterkeen/bugsplat.rb"
set :scm, :git
set :additional_domains, ['bugsplat.info']

role :web, "examplevps.bugsplat.info"
set :buildpack_url, "https://github.com/peterkeen/bugsplat-buildpack-ruby-simple"

set :user, "peter"
set :base_port, 6700
set :concurrency, "web=1"

set :deploy_env, {
  'LANG' => 'en_US.UTF-8',
  'PATH' => 'bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin',
  'GEM_PATH' => 'vendor/bundle/ruby/1.9.1:.',
  'RACK_ENV' => 'production',
}

load 'deploy'
require 'capistrano-buildpack'
```

This sets up the standard boilerplate Capistrano variables and roles, as well as `:buildpack_url` which controlls which buildpack to clone/update, as well as `:base_port`, `:concurrency`, and `:deploy_env` which tell [foreman][] and [foreman-export-nginx][] what to do. When you run `cap deploy` with this `Capfile`, these steps happen:

* Clone/update the buildpack
* Clone/update the code repository
* Apply the buildpack to the code repository
* Create `upstart`-style init files in `/etc/init` and start up the app
* Create an nginx config file at `/etc/nginx/conf.d/<application>.conf and restart nginx

The nginx config will set up one default hostname, `<application>.<deploy host>`, as well as list out the additional domains specified in the `:additional_domains` setting. Make sure to set up your DNS properly for these hostnames.

`capistrano-buildpack` defaults to deploying apps to `/apps/<application>`, nginx configs to `/etc/nginx/conf.d`, upstart files to `/etc/init`, and logs to `/var/log/apps/<application>-*.log`. Everything except the log path can be customized by setting these vars:

```ruby
set :deploy_to, "/your/path/#{application}"
set :foreman_export_path, "/your/init/path"
set :nginx_export_path, "/your/nginx/conf/path"
set :foreman_export_type, "runit_or_whatever"
```
    
Right now `Capistrano::Buildpack` will attempt to run `sudo service <application> restart` when running services. This may not be appropriate for all environments. If you want to generalizethis, please submit a pull request and I'll merge it.


