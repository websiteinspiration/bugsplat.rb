Title: Run Anything on Heroku with Custom Buildpacks
Date:  2012-11-05 18:13:41
Id:    9a2f7
Tags:  Programming, Heroku
Show_upsell: true

[Heroku][] is a Platform as a Service running on top of Amazon Web Services where you can run web applications written using various frameworks and languages. One of the most distinguishing features of Heroku is the concept of [Buildpacks][buildpack-devcenter], which are little bits of logic that let you influence Heroku as it builds your application. Buildpacks give you almost *unlimited flexibility* as to what you can do with Heroku's building blocks. 

Hanging out in the [#heroku][irc] irc channel, I sometimes see some confusion about what buildpacks are and how they work, and this article is my attempt to explain how they work and why they're cool.

[Heroku]: http://www.heroku.com
[buildpack-devcenter]: https://devcenter.heroku.com/articles/buildpacks
[irc]: http://webchat.freenode.net/?channels=heroku

--fold--

Before we tackle the specifics of a buildpack, let's talk about how Heroku works in more general terms. When you push your application to Heroku it turns your code into an executable *slug*, which includes your application code and all of it's dependencies. For a Ruby on Rails application, this would include every gem listed in your `Gemfile` along with the specific version of Ruby that you want. For a Python app it includes all of the dependencies listed in `requirements.txt`.

Heroku also generates or adds to a file named `Procfile` which lists all of the executable processes that your application uses. For example, most Ruby web applications will have an entry in their `Procfile` that looks like this:

```
web: bundle exec rackup -p $PORT
```

When you *scale* your application Heroku starts up little linux virtual machines named *dynos*. Each *dyno* corresponds to a particular slug and a particular set of environment variables set using `heroku config:add`, along with a single entry from your application's `Procfile`.

## What is a Buildpack?

Heroku turns your application code into a slug using a Buildpack which consists of a small set of executable scripts. We're going to use `heroku-buildpack-hello` ([github][heroku-buildpack-hello]) as a simple example.

### Stage 0: Buildpack Clone

The very first thing the slug compiler does is download your custom buildpack if you have one. You can set a custom buildpack at app creation time like this:

```
heroku create --buildpack=http://github.com/you/your-buildpack.git
```

After application creation you can set a custom buildpack or switch
to a different one by setting the `BUILDPACK_URL` configuration value:

```
heroku config:add BUILDPACK_URL=http://github.com/you/some-other-buildpack.git
```

If you haven't set a custom buildpack, Heroku uses their standard set
of buildpacks covering a wide variety of different language runtimes
and frameworks.

### Stage 1: Detect

Heroku runs `bin/detect` from each candidate buildpack, passing in the path to a temporary directory containing your application code. The first one that returns successfully (i.e. `exit 0` in bash) determines the buildpack to use in the next few stages. Here's `heroku-buildpack-hello`'s `detect`:

```
#!/bin/sh

# this pack is valid for apps with a hello.txt in the root
if [ -f $1/hello.txt ]; then
  echo "HelloFramework"
  exit 0
else
  exit 1
fi
```

The `if` statement looks for a specific file named `hello.txt` in the root directory of your app passed to `detect` as the first argument (in bash that's `$1`). 

Whatever `bin/detect` prints to `STDOUT` is used as the runtime label in the slug compiler output. In this case, `detect` prints `HelloFramework` which will result in this output:

```
-----> HelloFramework app detected
```

### Stage 2: Compile

The slug compiler next runs `bin/compile` passing in the path to your application code as well as a path to a directory the compiler can use as a build cache. Here's `heroku-buildpack-hello`'s `compile` script:

```
#!/bin/sh

indent() {
  sed -u 's/^/       /'
}

echo "-----> Found a hello.txt"

# if hello.txt is empty, abort the build
if [ ! -s $1/hello.txt ]; then
  echo "hello.txt was empty" | indent
  exit 1
fi

# replace hello with goodbye in a new file
cat $1/hello.txt | sed -e "s/[Hh]ello/Goodbye/g" > $1/goodbye.txt
```

Here we find a simple `indent()` function that indents output by eight spaces as recommended by the Heroku docs. Next, it prints out a log line that basically says everything is working as expected. It then tests to see if `hello.txt` is empty or not and aborts if it is. Finally it does the only real "compilation" step in this buildpack, which replaces `Hello` with `Goodbye`.

### Stage 3: Release

After the compilation step is done Heroku runs a script named `bin/release`. This takes the path to your application code as an argument and prints YAML to `STDOUT` describing default values for config variables and default `Procfile` entries. `release` can also specify default addons that your application should receive. For example, most release scripts will specify that the application will get a database instance by default. Here's `heroku-buildpack-hello`'s `release`:

```
#!/bin/sh

cat << EOF
---
addons:
  - shared-database:5mb
config_vars:
  PATH: bin:/usr/bin:/bin
default_process_types:
  hello: cat hello.txt
EOF
```

Notice that it specifies we should get a small database instance, that our application should receive a default `PATH` environment variable, as well as a default process named `hello` that just prints out the contents of `hello.txt`.

## Why is this cool?

Buildpacks are cool because you can do whatever you what in the compile step. Want to statically compile some pages in your app? Want to run an application with some parts written in Python and some in Haskell? Want to check in binaries and run them? All of this is possible. In addition to the [default buildpacks][defaults] here are some of the more interesting custom ones I've run across:

* [heroku-buildpack-multi][]: Run multiple buildpacks on your application
* [heroku-buildpack-ruby-jekyll][]: Build a static [Jekyll][] site at compile time
* [heroku-buildpack-static][]: Run an Apache webserver serving static HTML from a `public` directory.
* [heroku-buildpack-testrunner][]: A unit-testing framework for buildpacks

There's a [big list][third-party] of third-party buildpacks on Devcenter which I encourage you to check out.

## A Real Example: Vendoring Binaries

For [Docverter][] I've needed to include some 3rd party software that isn't packaged. For the first version I just included the binaries in my git repo, but that's pretty lame. Let's make a buildpack that pulls tarballs off of S3 and extracts them into the app directory.

First, the `detect` script:

```
#!/bin/bash

if [ -f $1/.vendor_urls ]; then
    echo "VendorBinaries"
    exit 0
else
    exit 1
fi
```

This script just looks for `.vendor_urls` in your app's root directory. Now, the compile script:

```
#!/bin/bash


indent() {
  sed -u 's/^/       /'
}

echo "-----> Found a .vendor_urls file"

# Bail early but noisily
if [ ! -s $1/.vendor_urls ]; then
  echo ".vendor_urls empty. Skipping." | indent
  exit 0
fi

cd $1

while read url; do
  echo Vendoring $url | indent
  curl -s $url | tar xz
done < .vendor_urls
```

From the top, this has the same `indent()` function as the `compile` from `heroku-buildpack-hello`. Then it checks the `.vendor_urls` file for validity and loops over the contents. Each line is fetched with `curl` and piped through `tar`.

Finally, the `release` script is very simple, just returning an empty YAML hash:

```
#!/bin/sh
echo "--- {}"
```

In my project's root directory I've created two files, `.buildpacks` which contains the list of buildpacks:

```
https://github.com/peterkeen/heroku-buildpack-vendorbinaries.git
https://github.com/heroku/heroku-buildpack-ruby.git
```

and a `.vendor_urls` file containing the list of binaries to vendor:

```
https://s3.amazonaws.com/my-bucket/pandoc.tar.gz
https://s3.amazonaws.com/my-bucket/calibre.tar.gz
```

I've created this buildpack and [put it on Github][heroku-buildpack-vendorbinaries] for you to use. This is just one example of the infinite variety of things you can do, so go forth and experiment!

[Docverter]: http://www.docverter.com
[defaults]: https://devcenter.heroku.com/articles/buildpacks#default-buildpacks
[heroku-buildpack-multi]: https://github.com/ddollar/heroku-buildpack-multi
[heroku-buildpack-hello]: https://github.com/heroku/heroku-buildpack-helo
[heroku-buildpack-ruby-jekyll]: https://github.com/mattmanning/heroku-buildpack-ruby-jekyll
[Jekyll]: https://github.com/mojombo/jekyll
[heroku-buildpack-static]: https://github.com/craigkerstiens/heroku-buildpack-static
[heroku-buildpack-testrunner]: https://github.com/ryanbrainard/heroku-buildpack-testrunner
[heroku-buildpack-vendorbinaries]: https://github.com/peterkeen/heroku-buildpack-vendorbinaries.git
[third-party]: https://devcenter.heroku.com/articles/third-party-buildpacks
