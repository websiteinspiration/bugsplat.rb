---
title: What is a CDN and why do I need one?
id: cdn2
tags: Programming
topic: Software
draft: true
description: A content delivery networks (CDN) speeds up your content delivery over the network. Simple!
---

In my [earlier post](https://www.petekeen.net/my-own-private-cdn) I talked about how I'm building my own *content delivery network* (CDN) but I didn't really go into what a content delivery network even is or why someone would want such a thing. A little back story is probably in order.

## What is a content delivery network?

A CDN is a set of computers distributed around the globe that all point back at the server where your website is actually hosted. The CDN computers (or nodes) run a piece of software called a *proxy*, which just grabs the content from your server and gives it to someone's web browser as if it was their own. Usually, but not always, the proxy *caches* the content (saves it to locally to it's own disk) so that the next web browser to come along doesn't have to wait for the origin server to respond, it just gets the saved content.

That's pretty much all there is to it. There's a standard way of telling a caching proxy (and a web browser, for that matter) exactly how long you want something cached and under what terms. Some commercial CDN offerings also let you write some code that executes at the cache itself, so you can do fancy things like modify requests on the fly before they hit your server.

## That's great, but do I need one?

It depends! A CDN buys you nothing if your audience is all in one spot and that spot is close to your server. On the other hand, if your website has a global (or even semi-regional) audience it will benefit by having caches scattered around the globe that can respond to requests. Ultimately response time is limited by the speed of light. A web browser on one side of the planet will have to wait 130ms *under the most ideal conditions* to hear back from a server on the other side, just due to how long it takes light to travel there and back. That doesn't include any kind of processing or disk access or buffering or anything. If you have a cache nearby the viewer's experience will be that much better because your site will seem that much more responsive.

Sites that serve the same files to lots of people are also prime candidates for CDNs. Take Netflix for example. Netflix, at one time, accounted over 20% of worldwide bandwidth usage. Their content consists of millions of tiny video files (each episode or movie is broken down into 15-30 second segments which are all encoded at a bunch of different bitrates to suit different speed connections). Netflix uses a huge fleet of servers that are all as close as possible to you, the customer, both to reduce the cost of transfering all those bits around and to make it faster for you to get to watching the latest episode of The Crown. Typically when you're accessing Netflix you're actually talking to a Netflix-owned server in your ISP's wiring closet, at least for the video content itself.

This site and the other sites I run don't get nearly that much traffic. I use a CDN because they take care of boring, error prone stuff for me. Right now most of my apps and sites live behind Amazon's CloudFront service because they automatically generate a free SSL certificate, for example. They renew it when it expires and generally let me ignore SSL completely.

The CDN I'm building for myself is also going to take care of SSL via LetsEncrypt, which is 100% free. It's also going to automatically manage the IPs of each site (which AWS does *not* do) so I don't have to care about DNS. It'll just automagically happen.

That's really the goal. Automatic, magical DNS/SSL/caching management.

## What's next?

My next post in this series will talk about the specific technologies that I'm using to power my CDN. Stay tuned!

<hr>

Want more stuff like this? [Sign up for my mailing list](https://www.petekeen.net/newsletter). I post everything there a week before I post it here.
