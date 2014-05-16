---
title: How and why I'm not running my own DNS
id: df11a
tags: DNS, Devops
show_upsell: 'true'
---

[route53]: http://aws.amazon.com/route53/
[how-i-run-my-own-dns]: /how-i-run-my-own-dns
[boto]: http://boto.readthedocs.org/en/latest/
[requests]: http://docs.python-requests.org/en/latest/

A few months ago I posted about [how I run my own DNS servers](/how-i-run-my-own-dns) using my virtual private servers and tinydns. Well, it turns out that's not a great idea, for a few reasons. First, because if I mess up I'm entirely shut out of my servers. I tried to turn off a service on them the other day and accidentally turned of the tinydns service instead and it took me ages to get back in. Running DNS on the same machines that handle email and web hosting for almost every piece of my online presence is just way too fragile.

--fold--

*You may be interested in my [other articles tagged with DNS](/tag/DNS)*

Second, and really more importantly, this happened:

<img class="thumbnail" src="https://d2s7foagexgnc2.cloudfront.net/files/35633efcdeb80dd81714/Screen%20Shot%202013-06-07%20at%204.41.49%20PM.png" alt="Papertrail has a lot of logs">

At some point last week I started seeing a very large number of queries for various domains coming into one of my servers. There were thousands of them a minute, supposedly coming from just a handful of machines. I couldn't figure this out, and the only solution I could reasonably come up with was to turn off logging. That's totally unacceptable, and if I couldn't figure this out I probably shouldn't be running DNS for myself after all. After consulting with a few very helpful people from the Internet we determined that my server was being used as part of a reflection attack originating at a known bad actor used for various command and control botnet nastiness. It was time to switch as soon as possible. Thankfully I had the TTL for my NS records set very low, otherwise this would have been a much more painful process.

## Route 53

Before I decided to go the route of self-hosting I had investigated a few different providers. The most promising of these was Amazon's [Route53][route53], with the small snag that there was no easy out of the box solution to dynamic DNS for my home machine. When it came time to switch I figured that a solution would present itself and charged forward with manually switching a few domains over.

At some point after moving my most important domains and turning the DNS service off for good on my VPSs I came up with this little script:

```python
#!/usr/bin/python

ZONE_ID = "ZXXXXXXXX"
DOMAIN_NAME = "dynamichost.example.com."

from boto.route53.connection import Route53Connection
from boto.route53.record import ResourceRecordSets
import requests
import sys

ip = requests.get("http://ip.example.com").text

conn = Route53Connection()

response = conn.get_all_rrsets(ZONE_ID, 'A', DOMAIN_NAME, maxitems=1)[0]
old_ip = response.resource_records[0]

if ip == old_ip:
    sys.exit(0)

changes = ResourceRecordSets(conn, ZONE_ID)

delete_record = changes.add_change("DELETE", DOMAIN_NAME, "A", 60)
delete_record.add_value(old_ip)

create_record = changes.add_change("CREATE", DOMAIN_NAME,"A", 60)
create_record.add_value(ip)

changes.commit()
```

This runs every minute on a VM running on the Mac mini in my living room. It uses [requests][] to get my external API from a tiny webservice running on one of my servers, and if it's changed from what Route53 thinks it is, it uses [boto][] to delete and recreate the A record. There's a bunch of public services out there that provide your external IP but I wanted to run my own. Of course.

Here's the code for the webservice:

```ruby
run lambda do |env|
    [200, {"Content-Type" => "text/plain"}, [Rack::Request.new(env).ip]]
end
```

I think I learned a valuable lesson about limits with this whole "host everything all the time" exercise. Namely, that DNS is best left to the professionals, just like outgoing email. Route53 isn't the cheapest provider around but they promise 100% uptime and have a very nice easy to work with API. I very much recommend them.
