Title: Simple Git-backed Microsites
Id:    sites
Tags:  Programming

A few days ago I built a new tool I'm calling [Sites](https://github.com/peterkeen/sites). It builds on top of git-backed wikis powered by GitHub's [Gollum](https://github.com/gollum/gollum) system and lets me build and deploy microsites in the amount of time it takes me to create a CNAME.

Something that I've wanted for a very long time is a way to stand up new websites with little more than a CNAME and a few clicks. I've gone through a few rounds of trying to make that happen but nothing ever stuck. Furthest progressed was a Rails app exclusively hosting [Comfortable Mexican Sofa](https://github.com/comfy/comfortable-mexican-sofa), a simple CMS engine. I never ended up putting any sites on it, though.

GitHub's Pages are of course one of the best answers, but I'm sticking to my self-hosting, built-at-home guns.

### A Short Code Tour

The code is split up into four distinct parts:

* [viewer](https://github.com/peterkeen/sites/blob/master/viewer.rb) is a [Sinatra](http://www.sinatrarb.com/) app that presents wiki content as web pages. It also can serve static assets right from the wiki repo and caches everything in an in-memory LRU cache. If you have a file `layout.erb` it will wrap the pages in that layout, otherwise it'll pass the content straight to the browser.

* [manager](https://github.com/peterkeen/sites/blob/master/manager.rb) is another Sinatra app that allows me to create new sites on the fly. Because a site is just a Gollum wiki and a Gollum wiki is just a git repo, it just has to create a git repo at the right place and do a redirect. It bakes in HTTP Basic Auth so other people can't create sites all willy nilly.

* some small [extensions to Gollum](https://github.com/peterkeen/sites/blob/master/gollum_ext.rb) add basic auth and override the method Gollum uses to find the correct wiki repo. By default Gollumn wants to be told exactly where the repo is in a class-level Sinatra setting, but that doesn't work when things are dynamic.

* a [Rack middleware](https://github.com/peterkeen/sites/blob/master/middleware.rb) ties it all together. The middleware has three jobs. If the incoming hostname maps to a CNAME that one of the sites has declared in a special wiki page named `cnames`, pass the request to the viewer app. Otherwise, either pass the request to Gollum for existing sites or to the manager to create a new site. The hard work of building the CNAME to site mapping is cached for a short period of time to minimize disk hits.

The neatest part about this setup is that, since sites are just git repos, I can clone the repo to my laptop and work with it in Emacs instead of directly editing in Gollum if I don't want to. This also lets me easily add asset files and layouts.

### Demo Time

Here's what the manager app presents when you just go to `sites.bugsplat.info`:

<img src="https://d2s7foagexgnc2.cloudfront.net/files/9eb9e104328da51fff72/manager.png">

I'm the only one that's ever going to be looking at this, so it doesn't really need to be anything fancy.

If you click on one of those links, you'll get the familiar Gollum interface:

<img src="https://d2s7foagexgnc2.cloudfront.net/files/210052500230dac13a38/gollum.png">

To create a new site, just append it's name to `sites.bugsplat.info`:

<img src="https://d2s7foagexgnc2.cloudfront.net/files/03f53229df6da8920ab3/create.png">

Notice the new little button. Clicking that creates the repo and sends you back to Gollum to populate the home page:

<img src="https://d2s7foagexgnc2.cloudfront.net/files/7cba47bcfdc430c509f4/editor.png">

If you want to see how the demo site is put together, it's running [here](http://demosite.petekeen.net) and the source is on GitHub [here](https://github.com/peterkeen/demosite).

### Installation

I built Sites to fit my infrastructure which is a delightful bastardization of [12 Factor](http://12factor.net/) so I haven't tried installing it elsewhere. I know it won't run properly on Heroku because it needs to be able to put the git repos in a persistent place, but it might work well as a Docker image. If you get it running somewhere please let me know and I'll link it here.



