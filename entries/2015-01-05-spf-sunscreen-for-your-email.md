---
title: "SPF: Sunscreen for your Email"
id: spf
tags: Email, DNS
topic: Email
show_upsell: true
description: "Sender Policy Framework (SPF) is a type of email deliverability record that helps servers that receive email verify the sender. This post is a deep dive into how it works and what it's good for."
---

Sender Policy Framework (SPF) is a type of email deliverability record that helps servers that receive email verify that the sender is allowed to send. It's been around for a few years and has been taken up by every large email provider. This post is a deep dive into how it works and what it's good for.

## Why do we need SPF?

The protocol that we use to send email from server to server, SMTP, allows anyone to set anything as their `From` or `MAIL FROM` (the envelope-from) address. Effectively, if I know your email address I can send messages as if I were you, and nobody would be the wiser unless they looked very closely at the message headers and compared them with previous messages from you.

SPF is a standard for declaring what servers can actually send on your behalf. An SPF record is attached to your domain name as a DNS TXT record. Domains that have SPF are less likely to be used by spammers and phishers, which means genuine messages coming from those domains will be given higher reputation with receiving servers.

## An Illustrative Example

Here is `bugsplat.info`'s SPF record:

```bash
$ dig +short bugsplat.info txt
v=spf1
  ip4:104.131.72.15
  ip4:192.241.250.244
  include:servers.mcsv.net
  include:_spf.google.com
  include:spf.messagingengine.com
  ~all
```

An SPF record consists of a version tag (`v=spf1`) followed by one or more mechanisms. There's a bunch of different mechanisms, along with a whole macro system that you can use to make things really complicated for yourself, but we're going to stick to the basics for now.

Mechanisms are matched from left to right, until something returns true. At a high level, this says that if the email is coming from one of those two IP's, it's good. In addition, any of the IPs listed in those `include`ed polices are also good.  The `google.com` one is pretty obvious, that means that Google's GMail servers can send as `bugsplat.info`. `servers.mcsv.net` is Mailchimp's address, and `spf.messagingengine.com` is for Fastmail.

The last mechanism, `~all`, will match everything that hits it. The tilde is a "qualifier" that means to fall through with a "soft fail" status. A soft fail basically says that the message came from an unknown source, but don't take action on it. The default qualifier is `+`, which means "accept the message". For the `ip4` and `include` mechanisms above, if they match the sending server then the message will be accepted.

`include` is actually sort of a misnomer, because the contents of the referenced record doesn't actually get included anywhere. Including another record means: evaluate the email against this entire other SPF declaration. If it matches, then return the qualifier on the `include` mechanism (by default, `+`). If it doesn't, continue on with the rest of the mechanisms. The only thing that causes a match when evaluating an `include` is a `+`. Soft fail, normal fail, and neutral all cause the `include` to not match.

## Limits

SPF records are limited to 10 total DNS lookups. Every `include` generates a DNS lookup, as do many other mechanisms including `ptr` and `a`. The only common mechanisms that don't are `all`, `ip4`, and `ip6`. This limit, along with a practical limit to DNS TXT records of 450 characters, means that adding a new mail provider to your setup is actually a big deal. You have to be careful to not exceed either of those limits, lest receiving servers start throwing permanent errors.

SPF also doesn't give much direction on what to actually *do* with a message that fails the checks. Generally your records should be set up to soft-fail, which means receiving servers shouldn't actually take any action other than maybe giving the message a higher spam rating. There's a newer, related standard named DMARC which you can use to actually declare a comprehensive policy. See my article Fix Your Deliverability with DMARC for more details on how to work it.

If you're interested in more SPF mechanisms the [official SPF webpage](http://www.openspf.org/SPF_Record_Syntax) has all the details. [This HOWTO](http://www.zytrax.com/books/dns/ch9/spf.html) goes into even more depth, along with an explanation of the SPF macro system, if you're so inclined.
