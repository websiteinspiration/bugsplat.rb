# bugsplat.rb

This is the software, as well as the content, that resides on [petekeen.net][].

## Features

* Easy to hack on
* Easy to deploy
* Flexible content

## Deploying

```bash
$ bundle exec cap deploy deploy:cleanup
```

[petekeen.net][] runs on a server in my basement and is served to the public using my [private CDN](https://www.petekeen.net/my-own-private-cdn). The deploy process uses `Capistrano` and `Capistrano::Buildpack`.

The application itself uses `Rack::FunkyCache` to dynamically render pages once. Thereafter they're served by `nginx` from disk. This gives most of the benefits of static rendering without actually having to render at deploy time.

## Contributing

I don't do guest posts on `petekeen.net`. If you have a code patch, email it to [bugsplat-rb-patch@petekeen.net](mailto:bugsplat-rb-patch@petekeen.net).

## Why the name?

Back in the day my blog ran on the domain name `bugsplat.info`. The original version of this software was a janky Perl script. This software is a ruby port/rewrite of that original script, thus `bugsplat.rb`.

## License

Copyright (c) 2010-2019 Pete Keen

[petekeen.net]: https://www.petekeen.net
