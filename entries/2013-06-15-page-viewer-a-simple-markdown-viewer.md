---
title: Page Viewer, a Simple Markdown Viewer
id: faeaa
tags: Programming
topic: Software
description: Page Viewer is a little Sinatra app that just renders a directory full of Markdown files into HTML.
---

[mmp]: /mastering-modern-payments
[page_viewer]: https://github.com/peterkeen/page_viewer
[Docverter]: http://www.docverter.com

For various projects including [Mastering Modern Payments][mmp] I've found it really useful to be able to view the Markdown source rendered as HTML but I don't really care about editing it online. I put together a little gem named [page_viewer][] which renders Markdown files like this:

<img src="https://d2s7foagexgnc2.cloudfront.net/files/bc0c9ca20f9b12269192/Screen%20Shot%202013-06-15%20at%2011.04.48%20PM.opti.png"/>

--fold--

`page_viewer` has some convenience features. First, it dynamically renders the markdown files for each request. This means that if the files change underneath there's no cache to refresh or anything. Second, code blocks are highlighted with Pygments. You'll need a working python installation but that's it. Third, it integrates with [Docverter][] for on-the-fly PDF conversion. 

It's also easy to subclass to do what you want. For example, the site where I'm developing my guide subclasses `PageViewer::App` to add some routes that render the whole guide as one page with a table of contents, and another one that renders the whole thing as a PDF.

I use an instance `page_viewer` to view my [personal wiki](/git-backed-personal-markdown-wiki) nicely rendered on a web page. My wiki repo is hosted on [my private gitolite instance](/hosting-private-git-repositories-with-gitolite) with a local clone. Each time I push changes, which happens pretty frequently with Sparkleshare, gitolite clones the repo to a directory somewhere else on the machine. This happens to be the same directory that `page_viewer` is pointing at.

Installation is pretty simple. Create a new project and include the `page_viewer` gem in the Gemfile:

```ruby
source :rubygems

gem 'page_viewer'
```

Configure and run `PageViewer::App` inside `config.ru`:

```ruby
require 'page_viewer'

PageViewer::App.set :page_root, '/path/to/some/markdown/files'

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == ENV['USERNAME'] && password == ENV['PASSWORD']
end

run PageViewer::App
```

`:page_root` needs to contain the path to the markdown files you want to render and is required. Every file in that path ending in `.md` will be renderable.

Is this going to be useful for other people? Probably not, since it's really specific to my own needs. If you have a dynamically changing set of markdown documents you want rendered fresh all the time, though, this may be the ticket.
