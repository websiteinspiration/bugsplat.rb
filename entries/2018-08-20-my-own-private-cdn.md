---
subject: My Own Private CDN
id: cdn1
tags: Programming
topic: Software
description: Yet another edition of Why Would You Ever Want To Do That
---

Hosting my own CDN has long been a completely irrational goal of mine.
*Wouldn't it be neat,* I'd think, *if I could tweak every knob instead of relying on CloudFront to do the right thing?*
Recently I read [this article](https://pasztor.at/blog/building-your-own-cdn) by Janos Pasztor about how he built a tiny CDN for his website. This just proves to me that at least it's not an *uncommon* irrational thought.

Yesterday I decided to actually start building something.
Even if it doesn't make it into production, I'll at least have learned something.

## Technical Goals

* Centrally manage all of the dozen or so sites that I run
* Automatically generate and renew LetsEncrypt certificates, both for publicly-facing sites and my own private sites. This means using the dns-01 challenge instead of using the easier to understand http challenge.
* Easily add new cache nodes with authenticated `curl | sudo bash`
* Automatically reconfigure `nginx` on the cache nodes when certificates roll or sites change
* Easily host sites anywhere, including the internet-inaccessible server in my basement
* Stop paying so much for bandwidth. Transfer is $5/tb/mo from DigitalOcean vs $$$$ for CloudFront.

Additionally, I really want to learn how LetsEncrypt works.
`certbot` is great but it is very much a black box to me.
Command-line arguments in, certificates out.
If I write my own management system I can actually learn how the guts work.

## Current Status

* basic Rails app that knows about sites and proxies
* creating or updating a site (re)generates a LetsEncrypt certificate for all of the domains that point at that site
* wildcard domains are fully supported
* authenticated endpoint that generates a zip file of all of the certificates and private keys

## Next Steps

* Automatic certificate refresh using something like [Sidekiq Cron](https://github.com/ondrejbartas/sidekiq-cron)
* Deploy onto the server in my basement on my [ZeroTier network](https://zerotier.com)
* Move all of my existing LetsEncrypt `certbot` crons into this system
* Provision a POP by hand and then automate the steps to provision another one

If you'd like to follow along I put the project up on [GitHub](https://github.com/peterkeen/diycdn).
I'll also be posting updates here as I go.
