---
title: Blog Relocation
id: '79934'
tags: Meta
topic: Updates
description: "I've moved my website to petekeen.net and managed the redirects like a pro."
---

[lol]: https://support.leagueoflegends.com/entries/20739888-Bug-Splat-and-Game-Crashes
[lush]: https://www.lush.co.uk/product/6328/Bugsplat
[drones]: http://www.cbc.ca/news/world/story/2013/02/07/f-drone-lexicon.html
[github]: https://github.com/peterkeen/bugsplat.rb/commit/9867cffa7d996f360acd82b28a8f1e5cf620f5b0
[rack-rewrite]: https://github.com/jtrupiano/rack-rewrite

After a lot of thought and deliberation I've decided to retire `bugsplat.info` as my blog address. It's served me well for about six years, but the word "bugsplat" has recently gained some [other][lol] [unrelated][lush] [connotations][drones], the latter being the most unsavory. The other big reason is that at this point I would like people to associate my work with my actual name, not some other name that you would only know was related if you knew me already.

That said, any `@bugsplat.info` email addresses you have will continue to work. Any links to `bugsplat.info` will also continue to work through the magic of HTTP `301 Moved Permanently`. Read on to see how I set that up, because it's kind of interesting.

--fold--

HTTP has a whole bunch of different status codes. Pretty much everyone knows about `404 Not Found`, of course. Other important codes are `200 Ok`, which is what servers respond to requests they can handle along with the content at that address. `401 Authorization Required` is another interesting one. That's what triggers a browser login box that you might see from time to time.

`301 Moved Permanently` (and its little brother `302 Moved Temporarily`) are used to tell your browser "hey, the content that you're looking for is over at this other location". Google also uses these redirections when generating search results, which is why they're so important to get right.

Along with changing the domain of this I wanted to change the URL format of blog posts. I'm pretty tired of having the date in the URL itself. It's long and redundant and kind of ugly. Some [small changes][github] to the application code took care of generating those URLs, but what to do about the redirects? I installed a new app at `bugsplat.info` running this code:

```ruby
require 'rack/rewrite'

use Rack::Rewrite do
  r301 %r{^/payment-integration.html}, "http://www.petekeen.net/mastering-modern-payments"
  r301 %r{^/\d{4}-\d{2}-\d{2}-(.*)$}, "http://www.petekeen.net/$1"
  r301 %r{^(.*).html$}, "http://www.petekeen.net$1"
  r301 %r{^(.*)$}, "http://www.petekeen.net$1"
end
run lambda { |env| [200, {"Content-Type" => "text/plain"}, ["Hello. The time is #{Time.now}"]] }
```

This app uses [rack-rewrite][], a small Rack middleware that emulates Apache's `mod_rewrite` but using a Ruby DSL. There's four specific rewrite instructions here. The first one rewrites the URL for my [guide to using Stripe with Rails](/mastering-modern-payments) to a URL matching it's actual title, which should help for SEO purposes. The next one sends old blog posts with the date and with `.html` at the end to the new site, sans date and suffix. The last two rules are generic catch-alls. Oh, and that little lambda thing is just there so the middleware has something to attach to, it's never actually called.

I think I caught all of the links on the site itself, but if you notice any weirdness with this new setup, please [let me know](mailto:pete@petekeen.net).
