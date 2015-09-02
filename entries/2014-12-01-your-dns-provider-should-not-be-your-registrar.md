---
title: Your DNS Provider Should Not Be Your Registrar
id: regis
topic: DNS
tags: DNS
description: By hosting your DNS nameservers at your DNS registrar you are exposing yourself to a large liability.
---

Hopefully, by time you're reading this DNSimple will have recovered from their [DDoS-powered outage](http://dnsimplestatus.com). Today has probably been a terrible day for everybody over there and I'm sure they're ready for a break. While *you* can't do much to directly defend against DDoS attacks, **you *can* insure yourself against DNS outages**.

--fold--

---

<a href="https://gumroad.com/l/MbhM">Buy the entire collection of DNS articles as a nicely formatted ebook.</a>

---

If you're a DNSimple customer right now or a NameCheap customer several times earlier this year, you know what happens when your DNS service goes out. Your website is inaccessible, emails are probably bouncing, and so are customers and their wallets. It's all around bad news.

**The cheapest insurance you can buy is to host your nameservers and your registrar at different companies.** That way, if your registrar gets attacked it's no big deal because they're not involved with your day-to-day name resolution, and if your nameservers are attacked *you can easily change them*. You can't do that if the web interface you need to use is down at the same time as your nameservers.

Splitting your DNS services between two or more companies adds a tiny bit of one-time overhead to setting up a new domain name, but the peace of mind this strategy buys is worth it. Your can be back up and servicing customers at a new DNS provider in as little as five minutes, depending on your registrar, while your previous/primary DNS provider is struggling with an attack for hours.

Personally, I use Amazon's [Route53](http://aws.amazon.com/route53/) service as my nameservers and either [Gandi](https://www.gandi.net) (for `.io`) or [Namecheap](https://www.namecheap.com) (for everything else) as my registrars, but you can use whoever you want. You could even use DNSimple as your registrar and Route53 as your nameserver if you want. The point is that you should have *at least two wholely separate companies involved*.

