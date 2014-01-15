---
title: Deploying a 12-Factor App with Capistrano
date: '2012-11-11 13:52:53'
id: c575a
tags: Programming, Heroku
---

[12-factor]: http://www.12factor.net/
[Foreman]: http://ddollar.github.com/foreman/
[Capistrano]: https://github.com/capistrano/capistrano
[buildpack]: https://devcenter.heroku.com/articles/buildpacks
[ledger-web]: https://github.com/peterkeen/ledger-web
[dokuen]: https://github.com/peterkeen/dokuen
[homebrew]: https://github.com/mxcl/homebrew

Deploying Heroku-style [12 factor applications][12-factor] outside of Heroku has been an issue for lots of people. I've written several different systems that scratch this particular itch, and in this post I'll be describing a version that deploys one particular app using a Heroku-style [buildpack][], [Foreman][], and launchd on Mac OS X via [Capistrano][].

--fold--

I've been deploying a customized version of [ledger-web][] on my Mac mini using [dokuen][] for almost six months. A few nights ago, however, I tried to deploy a version and discovered my Dokuen install was completely busted. Instead of doing the correct thing and fixing my Dokuen install I wrote a completely new deployment system using Capistrano.

Essentially, this deployment uses the standard `:checkout` deploy strategy with hooks that clone and run a buildpack, build a `.env` file, and run [Foreman][] to create launch scripts.

### Dependencies

This config depends on the following on the deployment target:

* Mac OS X
* Ruby 1.9.3 (installed from [homebrew][])
* the Foreman gem


### Configuration

There's a bunch of config that happens at the top of file. First, the standard config settings:

```ruby
set :application, "ledger"
set :repository,  "git@git.mydomain.com:peter/ledger-app.git"
set :deploy_to, "/Users/peter/apps/ledger"
set :scm, :git

role :web, "lionel.local"
role :db,  "lionel.local", :primary => true

set :user, "peter"
```

These define my app, the repository, and a few other standard things. It also sets my Mac mini, named `lionel` to be the deployment target.

```ruby
default_run_options[:pty] = true
default_run_options[:shell] = '/bin/bash'
```

`:pty` and `:shell` are required by several scripts that run later.

Next are settings that are used by my custom hooks:

```ruby
set :base_port, 6500
set :buildpack_url, "https://github.com/peterkeen/heroku-buildpack-ruby"
set :buildpack_hash, Digest::SHA1.hexdigest(buildpack_url)
set :buildpack_path, "#{shared_path}/buildpack-#{buildpack_hash}"
set :concurrency, "web=1"
set :launchd_conf_path, "/Users/peter/Library/LaunchAgents"
```

These set up my buildpack, more deployment paths, etc. Of particular note are `:concurrency`, which controls what Foreman exports, and `:base_port` which is what Foreman will set as the first port for the `web` procfile entries.

```ruby
set :deploy_env, {
  'DATABASE_URL' => 'postgres://user@dbhost/database',
  'LEDGER_FILE' => '/path/to/ledger.txt',
  'LEDGER_USERNAME' => 'username',
  'LEDGER_PASSWORD' => 'password',
  'LANG' => 'en_US.UTF-8',
  'PATH' => 'bin:vendor/bundle/ruby/1.9.1/bin:/usr/local/bin:/usr/bin:/bin',
  'GEM_PATH' => 'vendor/bundle/ruby/1.9.1',
  'RACK_ENV' => 'production',
}
```

`:deploy_env` sets up a hash of environment variables that will be exported later. I don't run `bin/release` because I found that it will always return the same set of environment variables and I don't care about the default procfile entries or addons. If you do, feel free to parse out the results of `bin/release`, which returns a YAML hash.

### Hooks

So now that the setup is done, deploy happens as normal with just a few hooks. First, a `before deploy` hook that sets up the buildpack and build cache:

```ruby
before "deploy" do
  run("[[ ! -e #{buildpack_path} ]] && git clone #{buildpack_url} #{buildpack_path}; exit 0")
  run("cd #{buildpack_path} && git fetch origin && git reset --hard origin/master")
  run("mkdir -p #{shared_path}/build_cache")
end
```

Next, after the normal deploy happens but before the symlink is switched, we hook in and run the buildpack:

```ruby
before "deploy:finalize_update" do
  run("cd #{buildpack_path} && bin/compile #{release_path} #{shared_path}/build_cache")

  env_lines = []
  deploy_env.each do |k,v|
    env_lines << "#{k}=#{v}"
  end
  env_contents = env_lines.join("\n") + "\n"

  put(env_contents, "#{release_path}/.env")
end
```

This hook also writes out the environment variables we defined earlier in a way that Foreman can pick up.

Finally, we redefine the `deploy:restart` task to run Foreman and restart the generated LaunchAgent:

```ruby
namespace :deploy do
  task :restart do
    sudo "launchctl unload -wF #{launchd_conf_path}/ledger-web-1.plist; true"
    sudo "foreman export launchd #{launchd_conf_path} -d #{release_path} -l /var/log/#{application} -a #{application} -u #{user} -p #{base_port} -c #{concurrency}"
    sudo "launchctl load -wF #{launchd_conf_path}/ledger-web-1.plist; true"
  end
end
```

This hardcodes the `plist` name that Foreman generates because it was late and I was tired. Also, `sudo` didn't like my initial stab at a `for` loop and I cut my losses. It wouldn't be too hard to write out a tiny script and execute it, though.

### Nginx

Dokuen was also managing my nginx configuration for each app. I added a simple proxy definition for `ledger` instead:

```nginx
server {
  server_name ledger.mydomain.com;
  listen 443;
  ssl on;
  location / {
    proxy_pass http://localhost:6500/;
  }
}
```

### Result

At this point I think this is a better model than Dokuen for deploying 12 factor applications on my own hardware. There are no extra daemons to keep running, there's no extra software on the server (except Foreman), there's no weird sudo definitions.

Deploying on a cluster is a slightly different story. I would probably change this do build a tarball on an Anvil server and then distribute the tarball out to the rest of the machines instead of building on every machine, among other changes.

