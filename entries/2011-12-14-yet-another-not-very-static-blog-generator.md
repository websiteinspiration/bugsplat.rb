---
title: Yet Another (not very) Static Blog Generator
date: '2011-12-14 18:30:26'
tags: Meta
id: 7e074
topic: Updates
description: The second major version of the engine that runs this site is a small Ruby/Sinatra application.
---

[firstpost]: /yet-another-static-html-generator
[mustache]: http://mustache.github.com/
[Sinatra]: http://www.sinatrarb.com/
[bugsplat.rb]: http://github.com/peterkeen/bugsplat.rb
[Heroku]: http://www.heroku.com
[unicorn]: http://unicorn.bogomips.org/
[concurrency]: /concurrency-on-heroku-cedar
[Jekyll]: https://github.com/mojombo/jekyll

The [very first post on this blog][firstpost] was about how I wanted a completely static blog and how it'll be great and wonderful and boy howdy was it ever. Over 500 lines of rather dense perl plus almost 20 separate template files because the kind-of-[mustache][] that I decided to implement can't handle inlined templates for loops so I have to do everything as partials. 

Needless to say, it isn't very fun to work on. It mostly does what I want but adding new things is pretty painful, as is changing any of the templates. Yesterday I decided that I would see what a [Sinatra][] port would look like. Why Sinatra? It's fun, that's why. Ruby and Sinatra make writing new webapps easy and fun.

--fold--

#### Details

The new version is called [bugsplat.rb][]. It's 200 lines of ruby, which is actually more than I wanted but there a lot of functionality packed in there. Here's the complete feature set:

* Entries are written in Markdown and checked into the app repo
* Entries have a MIME-style header
* Entries can have a `--fold--` marker that specifies which content should be on the index page
* Supports blog posts and static entries that can optionally be linked from the side navigation
* Reads all entries into memory at startup
* Uses ERB for templates
* Caches rendered pages in memory

The production site is hosted on [Heroku][] and uses a [unicorn][] extremely similar to [FivePad's setup][concurrency] without the background worker stuff.

#### Why not some other blog engine?

A while ago I tried porting to [Jekyll][] but without heavy modification I wouldn't have been able to keep the URLs I've built up over the last year and a half. Also for some reason I couldn't wrap my head around liquid templates.

Wordpress or some other dynamic CMS? I could have done that, sure, but that would introduce other dependencies and I really like the emacs-centric workflow of writing markdown files and generating a site. A web-based CMS would have let me write from anywhere but then I'd have to write in the browser, which isn't my idea of fun.

#### Results

It's not a static site anymore but I think with the caching I have set up it's almost as fast as one. I could even transparently make it one by pre-rendering everything and stashing it in `public` using a `rake` task named `assets:precompile` that Heroku conveniently runs if it exists.

I don't think I'll do that, though. I like the flexibility that this setup gives me. 

#### Re-using

I wouldn't recommend it. There's nothing that precludes someone else forking [bugsplat.rb][] on github, deleting the entries, rewriting the templates, and running their own site, of course, but it wouldn't be trivial. If you actually want to use it on your own site, [email me](mailto:pete@bugsplat.info) or leave a comment below and we'll work something out.
