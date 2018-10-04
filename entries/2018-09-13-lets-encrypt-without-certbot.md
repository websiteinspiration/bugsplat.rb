---
title: "DIY CDN Part 3: Using Let's Encrypt Without certbot"
draft: true
id: cdn3
---

In my last post I talked about what a CDN is and why you might want one.
To recap, my goal is automatic, magical DNS/SSL/caching management.
Today we're going to talk about one aspect of this project, SSL.

SSL, or *Secure Sockets Layer*, in the context of the web, is a mechanism for securing and encrypting the connection between your browser and the server that is serving up the content you're looking for.

A few years ago browser vendors started getting very serious about wanting every website to be encrypted.
At the time SSL was expensive to implement because you needed to buy or pay to renew certificates at least once a year.

Almost simultaneously with this increased need for encryption, organizations including the Electronic Frontier Foundation and the Mozilla Foundation started a new certificate authority (organization that issues certificates) named Let's Encrypt.
Let's Encrypt is different because it issues certificates for free with an API.

Most people use a tool named `certbot` that automates the process of acquiring certificates for a given website.
However, `certbot` doesn't really work for my purposes.
I want to centrally manage my certificates and copy them out to my CDN nodes on a regular basis.
I also want to use the DNS challenge instead of the HTTP challenge.

## Challenge Types

Let's Encrypt uses *challenges* to verify that you own the domain that you're trying to acquire a certificate for.
Currently there are two different challenge types, `http-01` and `dns-01`.

For `http-01`, you simply create a file within a well-known directory structure within your website containing a challenge string that the API gives you.
Then you tell Let`s Encrypt to go look for it.
If the file is there and contains the correct challenge string, Let's Encrypt will give you a certificate.

`dns-01` works much the same way, except instead of creating a file you create a `TXT` record for your domain.
Let's Encrypt will ask your domain's DNS servers for the value of the `TXT` record, and if it matches what it expects, you get a certificate.

`http-01` has the advantage of being really simple and easy to use with the `certbot` tool and whatever web server you happen to have.
However, with multiple servers in the mix it can get tricky to make sure that every server has a certificate without hitting Let's Encrypt's rate limits.

That's why I'm using `dns-01`.
I can easily drive the API from the central management node and copy the certificates out to all of the CDN nodes simultaneously.

## Driving the API with Ruby

I use a gem called [`acme-client`](https://github.com/unixcharles/acme-client) to drive Let's Encrypt `ACMEv2` API.
It's fairly easy to use if you know ACME's terminology.

* an `order` is the initial request to 

## Getting a Certificate, End to End

## Wildcard Wrinkles

