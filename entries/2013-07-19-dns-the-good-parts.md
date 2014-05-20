---
title: ! 'DNS: The Good Parts'
id: dns
tags: DNS
show_upsell: 'true'
topic: DNS
description: Dig through the DNS and learn how and why it all works.
---

Frequently I come across confusion with domain names. *Why doesn't my website work? Why is this stupid thing broken, everything I try fails, I just want it to work!!* Invariably the question asker either doesn't know what DNS is or doesn't understand how something fundamental works. More generally, people think that DNS is scary or complicated. This article is an attempt at quelling that fear. *DNS is easy* once you understand a few basic concepts.

--fold--

*You may be interested in my [other articles tagged with DNS](/tag/DNS)*

## What is DNS

First things first. *DNS* stands for *Domain Name System*. Fundamentally it's a globally distributed key value store. Servers around the world can give you the value associated with a key, and if they don't know they'll ask other servers for the answer.

That's it. That's all there is to it. You (or your web browser) ask for the value associated with the key `www.example.com` and get back `1.2.3.4`.

## Basic Exploration and Fundamental Types

The great thing about the DNS is that it's completely public and open so it's easy to poke around. Let's do a little exploring, starting with this domain, `petekeen.net` which I am hosting on a machine named `web01.bugsplat.info`. Note that you can run all of these examples from an OS X or linux command line.

First, let's look at a simple domain name to IP address mapping:

```bash
$ dig web01.bugsplat.info
```

The `dig` command is a veritable Swiss Army knife for querying DNS servers and we'll be using it quite a bit. Here's the first part of the response:

```bash
; <<>> DiG 9.7.6-P1 <<>> web01.bugsplat.info
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 51539
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
```

There's only one interesting thing in here. We asked for one record and got exactly one respose. Here's the question we asked:

```bash
;; QUESTION SECTION:
;web01.bugsplat.info.		IN	A
```

`dig` defaults to asking for `A` records. `A` stands for *address* and is one of the basic fundamental types of records in the DNS. An `A` record holds exactly one `IPv4` address. There's an equivalent record for `IPv6` addresses named `AAAA`. Next, let's look at the answer our DNS server gave us:

```bash
;; ANSWER SECTION:
web01.bugsplat.info.	300	IN	A	192.241.250.244
```

This says the host `web01.bugsplat.info.` has exactly one `A` address: `192.241.250.244`. The `300` is called the `TTL` value, or *time to live*. It's the number of seconds that this record can be cached before it needs to be checked again. The `IN` component stands for `Internet` and is meant to disambiguate between the various types of networks that the DNS historically was responsible for. You can read about those in [IANA's DNS Parameters document](https://www.iana.org/assignments/dns-parameters/dns-parameters.xhtml#dns-parameters-2) (thanks for the correction, [mcmatterson](https://news.ycombinator.com/item?id=6075525)!)

The rest of the response tells you things about the response itself:

```bash
;; Query time: 20 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
;; WHEN: Fri Jul 19 20:01:16 2013
;; MSG SIZE  rcvd: 56
```

Specifically, it tells you how long it took for your server to respond, what that server's IP address is (`192.168.1.1`), what port `dig` asked (`53`, the default DNS port), when the query completed, and how many bytes the response contained.

As you can see, there's an awful lot going on in a single DNS query. Every time you open a web page your browser makes literally dozens of these queries to resolve the web host, all of the hosts where external resources like images and scripts are located, etc. Every single resource involves at least one DNS query, which would involve an awful lot of traffic if DNS wasn't designed to be heavily cached.

What you probably can't see, however, is that the DNS server at `192.168.1.1` contacted a whole chain of other servers in order to answer that simple question of what address does `web01.bugsplat.info` map to. Let's run a trace to see all of the servers that `dig` would have to contact if they weren't already cached:

```bash
$ dig +trace web01.bugsplat.info

; <<>> DiG 9.7.6-P1 <<>> +trace web01.bugsplat.info
;; global options: +cmd
.			137375	IN	NS	l.root-servers.net.
.			137375	IN	NS	m.root-servers.net.
.			137375	IN	NS	a.root-servers.net.
.			137375	IN	NS	b.root-servers.net.
.			137375	IN	NS	c.root-servers.net.
.			137375	IN	NS	d.root-servers.net.
.			137375	IN	NS	e.root-servers.net.
.			137375	IN	NS	f.root-servers.net.
.			137375	IN	NS	g.root-servers.net.
.			137375	IN	NS	h.root-servers.net.
.			137375	IN	NS	i.root-servers.net.
.			137375	IN	NS	j.root-servers.net.
.			137375	IN	NS	k.root-servers.net.
;; Received 512 bytes from 192.168.1.1#53(192.168.1.1) in 189 ms

info.			172800	IN	NS	c0.info.afilias-nst.info.
info.			172800	IN	NS	a2.info.afilias-nst.info.
info.			172800	IN	NS	d0.info.afilias-nst.org.
info.			172800	IN	NS	b2.info.afilias-nst.org.
info.			172800	IN	NS	b0.info.afilias-nst.org.
info.			172800	IN	NS	a0.info.afilias-nst.info.
;; Received 443 bytes from 192.5.5.241#53(192.5.5.241) in 1224 ms

bugsplat.info.		86400	IN	NS	ns-1356.awsdns-41.org.
bugsplat.info.		86400	IN	NS	ns-212.awsdns-26.com.
bugsplat.info.		86400	IN	NS	ns-1580.awsdns-05.co.uk.
bugsplat.info.		86400	IN	NS	ns-911.awsdns-49.net.
;; Received 180 bytes from 199.254.48.1#53(199.254.48.1) in 239 ms

web01.bugsplat.info.	300	IN	A	192.241.250.244
bugsplat.info.		172800	IN	NS	ns-1356.awsdns-41.org.
bugsplat.info.		172800	IN	NS	ns-1580.awsdns-05.co.uk.
bugsplat.info.		172800	IN	NS	ns-212.awsdns-26.com.
bugsplat.info.		172800	IN	NS	ns-911.awsdns-49.net.
;; Received 196 bytes from 205.251.195.143#53(205.251.195.143) in 15 ms
```

The DNS is arranged in a hierarchy. Remember how `dig` inserted a single `.` after the hostname we asked for before, `web01.bugsplat.info`? Well, that `.` is pretty important and stands for the root of the hierarchy. The root DNS servers are run by various companies and governments around the world. Originally there were only a handful of these servers but as the Internet has grown more have been added, so that now there are notionally 13. Each one of these servers, however, has dozens or hundreds of physical machines hiding behind a single IP.

So, at the top of the trace we see the root servers, each represented by an `NS` record. An `NS` record maps a domain name, in this case the root, to a DNS server. When you register a domain name with a registrar like Namecheap or Godaddy they create `NS` records for you.

In the next block you can see that `dig` randomly picked one of the root server responses and asked it for the `A` record  `web01.bugsplat.info`. Which root server? Let's ask!

```bash
$ dig -x 192.5.5.241

; <<>> DiG 9.8.3-P1 <<>> -x 192.5.5.241
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 2862
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;241.5.5.192.in-addr.arpa.	IN	PTR

;; ANSWER SECTION:
241.5.5.192.in-addr.arpa. 3261	IN	PTR	f.root-servers.net.
```

The `-x` flag tells `dig` to do a reverse lookup on the given IP address. The DNS responds with a `PTR` record which maps an IP with a hostname, in this case `f.root-servers.net`.

Getting back to our original query, the `F` root server responded with another set of `NS` servers, this time the ones responsible for the `info` top level domain. `dig` asks one of these servers for the `A` record for `web01.bugsplat.info`, gets back another set of `NS` servers, and then asks one of *those* servers for the `A` record for `web01.bugsplat.info.` and finally receives an actual answer. (thanks for the corrections, [colmmacc](https://news.ycombinator.com/item?id=6075556)!)

Whew! That would be a heck of a lot of traffic, except that almost all of these entries are cached for a long time by every server in the chain. Your computer caches too, as does your browser. Most of the time DNS resolution will never touch the root servers because their IP addresses hardly ever change. The top level domains `com`, `net`, `org`, etc, are also generally heavily cached.

### Other Types

There are a few other types that you should be aware of. The first is `MX`, which maps a domain name to one or more email servers. Email is so important to the functioning of the Internet that it gets its own record type. Here are the `MX` records for `petekeen.net`:

```bash
$ dig petekeen.net mx

; <<>> DiG 9.7.6-P1 <<>> petekeen.net mx
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18765
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;petekeen.net.			IN	MX

;; ANSWER SECTION:
petekeen.net.		86400	IN	MX	60 web01.bugsplat.info.

;; Query time: 272 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
;; WHEN: Fri Jul 19 20:33:43 2013
;; MSG SIZE  rcvd: 93
```

Note that an `MX` record points at a name and not an IP address.

The other record type that you should be familiar with is `CNAME` which stands for *Canonical Name* and maps one name onto another. Let's look at the response we get for a `CNAME`:

```bash
$ dig www.petekeen.net

; <<>> DiG 9.7.6-P1 <<>> www.petekeen.net
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16785
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;www.petekeen.net.		IN	A

;; ANSWER SECTION:
www.petekeen.net.	86400	IN	CNAME	web01.bugsplat.info.
web01.bugsplat.info.	300	IN	A	192.241.250.244

;; Query time: 63 msec
;; SERVER: 192.168.1.1#53(192.168.1.1)
;; WHEN: Fri Jul 19 20:36:58 2013
;; MSG SIZE  rcvd: 86
```

The first thing to notice is that we get back two answers. The first says that `www.petekeen.net` maps to `web01.bugsplat.info`. The second gives the `A` record for that server. One way to think about a `CNAME` is as an *alias* for another domain name.

### Why CNAME is Messed Up

`CNAME`s are incredibly useful, but they have one very important gotcha: if there a `CNAME` exists for a particular name, that is the *only* record allowed for that name. No `MX`, no `A`, no `NS`, no nothing. This is because the DNS substitutes the `CNAME`'s target for its own value, so every record valid for the target is also valid for the `CNAME`. This is why you can't have a `CNAME` on a root domain like `petekeen.net`, because you generally have to have other records for that domain like `MX`.

### Querying Other Servers

Let's say for sake of argument that you messed up a DNS configuration. You think you've fixed the problem, but you don't want to wait for the cache to expire to see. With `dig` you can actually query one of a number of public DNS servers instead of your default server like this:

```bash
$ dig www.petekeen.net @8.8.8.8
```

The `@` symbol followed by an IP address or hostname tells `dig` to query that server on the default DNS port. I use this a lot to query [Google's public DNS servers](https://developers.google.com/speed/public-dns/) or [Level 3's sort-of-public servers](http://www.tummy.com/articles/famous-dns-server/) at `4.2.2.2`.

## Common Situations

In this last section we'll talk about some common situations that web developers find themselves in. 

### Redirect bare domain to www

Almost always you'll want to redirect a bare domain like `iskettlemanstillopen.com` to `www.iskettlemanstillopen.com`. Registrars like Namecheap and DNSimple call this a *URL Redirect*. In Namecheap you would set up a URL Redirect like this:

<img src="https://d2s7foagexgnc2.cloudfront.net/files/3abc3ac12462e5a92ae7/Screen%20Shot%202013-07-19%20at%208.48.36%20PM.png" alt="Namecheap URL redirect setup" class="thumbnail">

The `@` stands for the root domain `iskettlemanstillopen.com`. Let's look at the `A` record for that domain:

```bash
$ dig iskettlemanstillopen.com
;; QUESTION SECTION:
;iskettlemanstillopen.com.	IN	A

;; ANSWER SECTION:
iskettlemanstillopen.com. 500	IN	A	192.64.119.118
```

That IP is owned by Namecheap and is running a small web server that just serves up an HTTP-level redirect to `http://www.iskettlemanstillopen.com`:

```bash
$ curl -I iskettlemanstillopen.com
curl -I iskettlemanstillopen.com
HTTP/1.1 302 Moved Temporarily
Server: nginx
Date: Fri, 19 Jul 2013 23:53:21 GMT
Content-Type: text/html
Connection: keep-alive
Content-Length: 154
Location: http://www.iskettlemanstillopen.com/
```

### CNAME to Heroku or Github

Notice in the screenshot above that there's a second row defining a `CNAME`. In this case `www.iskettlemanstillopen.com` maps to an application running on Heroku. You'll have to set up Heroku with a similar domain mapping, of course:

```bash
$ heroku domains
=== warm-journey-3906 Domain Names
warm-journey-3906.herokuapp.com
www.iskettlemanstillopen.com
```

Github is similar, except that the mapping lives in a file called `CNAME` at the root of your pages, as described [in their documentation](https://help.github.com/articles/setting-up-a-custom-domain-with-pages).

### Wildcards

Most DNS servers allow you to set up DNS wildcards. For example, I have a wildcard `CNAME` set up for `*.web01.bugsplat.info` that maps to `web01.bugsplat.info`. That way I can host arbitrary things on `web01` and not have to create new DNS entries for them every time:

```bash
$ dig randomapp.web01.bugsplat.info

;; QUESTION SECTION:
;randomapp.web01.bugsplat.info. IN	A

;; ANSWER SECTION:
randomapp.web01.bugsplat.info. 300 IN CNAME	web01.bugsplat.info.
web01.bugsplat.info.	15	IN	A	192.241.250.244
```

## Wrap Up

Hopefully this gives you a good beginning understanding of what DNS is and how to about exploring and verifying your configuration. Just remember that you can always ask the DNS questions and generally get back answers. The Internet standards (RFCs) that define DNS are:

* [RFC 1034: Domain Names - Concepts and Facilities](http://www.ietf.org/rfc/rfc1034.txt)
* [RFC 1035: Domain Names - Implementation and Specification](http://www.ietf.org/rfc/rfc1035.txt)

There are a few more interesting RFCs as well, including [4034](http://www.ietf.org/rfc/rfc4034.txt) about a standard named `DNSSEC` and [5321](http://www.ietf.org/rfc/rfc5321.txt) which talks about DNS as it relates to email. These are all fascinating reads if you want more background information

*This article is featured in [Hacker Monthly issue 42](http://hackermonthly.com/issue-42.html).*
