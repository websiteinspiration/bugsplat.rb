Title: Dokuen, a Personal App Platform
Date:  2012-05-17 16:29:30
Tags:  Heroku, Projects
Id:    76c93

Dokuen (Japanese for "solo performance") is an amalgamation of open source components that I mashed together so I could run [Heroku](http://heroku.com)-style services on my shiny new Mac mini while retaining the paradigm of `git push` deployments and environment variables for configuration. Effectively, I wanted to be able to seamlessly deploy [12 factor applications](http://12factor.net) in my local environment.

*Update: I've rewritten Dokuen and released it as a gem. See [this article](/2012-05-20-dokuen-update.html) for details.*

*Update 2: I've added [linux support](/2012-05-29-dokuen-0-0-6-now-with-linux-support.html).*

--fold--

The whole idea started when I got a new mini and wanted to exploit it as much as possible. It's so low power and it's mostly just sitting around doing nothing, so it might as well run some interesting things. For example, I have a personal note-taking app that is currently running on Heroku but storing that kind of data on a 3rd party server kind of makes me nervous. I have another app that contains all of my finances that I wouldn't ever want to live on another server, but up til now there was no where to put it other than my laptop.

Heroku is super cool, though, and [David Dollar](http://twitter.com/ddollar) has extracted a lot of very interesting things from the Cedar platform that I've been itching to try. Dokuen is thus a learning lark wrapped in a good excuse. The best combination.

## Components

Dokuen breaks down into two piles, **platform** and **application** The platform consists of:

* [Gitolite](https://github.com/sitaramc/gitolite)
* [Mason](https://github.com/ddollar/mason)
* [Foreman](https://github.com/ddollar/foreman)
* [Nginx](http://wiki.nginx.org/Main)
* [envdir](http://cr.yp.to/daemontools/envdir.html)

Gitolite is the core of the whole system. In this application I'm using it for it's simple repo creation and configuration, as well as the ability to stick an arbitrary git hook in every repo.

Mason and Foreman are the two Heroku projects that I'm using. Mason consumes an application clone and one or more buildpacks and produces an application instance that can be run using Foreman. `envdir`, from the `daemontools` package, manages environment variables. Nginx proxies from a CNAME subdomain to the actual running application.

Applications are actually launched in a slightly round-about way. The `pre-receive` hook generates a `launchd` plist file and drops it in `/Library/LaunchDaemons` and then unloads/reloads it. This config file just runs foreman with the configured environment and concurrency settings. Foreman has the capability to generate these types of configs, but it felt more natural to use it to run the code directly.

The applcation side of things consists of:

* [buildpacks](https://devcenter.heroku.com/articles/buildpacks)
* [PostgreSQL](http://www.postgresql.org/)
* [astrails-safe](https://github.com/astrails/safe)
* [jgit](http://www.jgit.org/)

Buildpacks are a really neat concept for a platform. They consist of a trio of scripts: `detect` says if the buildpack applies to the application in question, `compile` builds a runnable application instance (compiles, installs gems, runs setup.py, whatever), and `release` returns metadata about the application that the platform needs. I'm exploiting the sweat and tears that the Heroku devs obviously poured into these buildpacks for my own selfish needs in Dokuen, and they fit very very well.

`astrails-safe` is a small backup system that knows how to talk to both S3 and PostgreSQL, putting dumps from the latter into the former. I've cron'd it to run nightly.

I'm using `jgit` because it's been blessed with the ability to push and pull git repos to S3, which means it's convenient to use for git backups. Every repo in my gitolite install gets a post-receive hook that provides a world-class backup for pennies a month.

PostgreSQL doesn't really need explanation. It's awesome. Use it.

## Caveats

There are some obvious flaws in this thing I put together in a day (shocker) that I'll be working on rectifying. First of all, way too much information is in the git config. I thought this was very clever at the time but it turns out it's not very flexible at all. Second, the code is terrible. I think the approach is fundamentally sound, but it's one big monolithic script right now. Third, there are a lot of places where things are hard-coded for my setup, especially around the Nginx and LaunchDaemon configs.

Dokuen is *extremely* rough right now. If I were you I wouldn't try to use it directly. The scripts that tie everything together are on [github](https://github.com/peterkeen/dokuen-scripts) if you want to take a look, though, and perhaps derive some inspiration.
