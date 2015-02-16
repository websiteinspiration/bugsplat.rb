# bugsplat.rb

This is the software, as well as the content, that resides on [petekeen.net][]. It's a Sinatra application that renders Markdown into HTML and PDF.

## Features

* Easy to hack on
* Easy to deploy
* Flexible content
* (mostly) static with the ability to add dyanmic routes

## Deploying

```bash
$ bundle exec cap deploy deploy:cleanup
```

[petekeen.net][] runs on a virtual machine at Digital Ocean named `web01.bugsplat.info`. The deploy process uses [Capistrano::Buildpack][] and exports most pages as HTML, PDF (using [Docverter][], as well as a slightly-simplified form of Markdown. These files are then served up by Nginx.

## Dynamic Routes

`bugsplat.rb` provides several dynamic routes as well:

* `/projects` lists my [open source projects](https://www.petekeen.net/projects) and various side projects that I've worked on
* `/projects/:project_name` renders the `README.md` file from each project.
* `/source` is an instance of [Grack](https://github.com/schacon/grack) that actually serves up my open source projects
* `/subscribe` signs people up to my mailing lists
* `/checkup-apply-form` handles the application form for [Stripe Checkup](https://www.petekeen.net/checkup)
* `/ping` is a simple active health check

## Contributing

I don't do guest posts on `petekeen.net`. If you have a code patch, email it to [bugsplat-rb-patch@petekeen.net](mailto:bugsplat-rb-patch@petekeen.net).

## License

Copyright (c) Okapi, LLC

Code (everything in a `.rb` file): MIT

Content (everything else):  All rights reserved

[petekeen.net]: https://www.petekeen.net
[Capistrano::Buildpack]: https://www.petekeen.net/projects/capistrano-buildpack
[Docverter]: http://www.docverter.com


Test issue linking #1
