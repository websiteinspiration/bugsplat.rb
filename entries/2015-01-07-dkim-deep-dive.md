---
title: DKIM Deep Dive
id: dkim
tags: Email, DNS, _evergreen
topic: Email
description: "DKIM (DomainKeys Identified Mail) is another type of email deliverability record that helps recipient servers be confident that you authorized any given email. This post is a deep dive into how it works and what it's good for."
---

DKIM (DomainKeys Identified Mail) is another type of email deliverability record that helps recipient servers be confident that you authorized any given email. DKIM uses public-key-cryptography to mathematically sign important parts of your messages. This post is a deep dive into how it works and what it's good for.

## Why do we need DKIM?

Like SPF, [DKIM](http://www.dkim.org) protects your domain against spammers and phishers by validating your legitimate mail. Mail that purports to come from you and doesn't have a DKIM signature is more suspicious and more likely to be put into recipient's spam folder.

DKIM uses the DNS in a similar way as SPF. When you deploy DKIM, you insert keys into your DNS records at specifc URLs, thus proving that you control your DNS records.

## An Example

DKIM has more moving parts than SPF. Specifically, there are:

* Records in your DNS settings that contain public keys
* Private keys on your mail server
* Cryptographic signatures embedded in your messages

We're going to explore each one of these in turn.

### DNS Records

DKIM public keys are stored as TXT records on your domain, under the subdomain `_domainkey`. As an example, here's the DKIM key that Mandrill uses when sending as `petekeen.net`:

```bash
$ dig +short mandrill._domainkey.petekeen.net txt
"v=DKIM1\; k=rsa\; p=RSA_PUBLIC_KEY>\;"
```

DKIM records are always key-value separated by semicolons (the backslashes come from the `dig` tool, they don't actually need to be there). In this case there are three parts. `v=DKIM1` says that this is a DKIM version 1 key. `k=rsa` says that this is an RSA public key. `p=RSA_PUBLIC_KEY_DATA` is the actual public key (I removed the data just because it's so big. Run the `dig` command to see the data).

Unless you're running your own mail server, you'll almost always get the value for this record from your email provider. It'll be buried in your account settings, usually under a header like "Verified Domains".

### Private Keys

The private key that corresponds to the public key in your DNS lives on the mail server. If you're using an email service provider like Mandrill, Postmark, or Mailgun they handle this for you. If you're running your own mail server you'll need to handle it yourself, which is out of scope for this post.

### Embedded Message Signature

When a mail server wants to send a DKIM-signed message, it first calculates a cryptographic signature for the body and certain headers. Here's an example from a message I sent a few days ago:

```text
DKIM-Signature:
  v=1;
  a=rsa-sha1;
  c=relaxed/relaxed;
  s=mandrill;
  d=petekeen.net;
  h=From:Subject:To:Message-Id:Date:MIME-Version:Content-Type;
  i=pete@petekeen.net;
  bh=82iZmY7kCbFDunaEckImLSxqHv8=;
  b=IQK/KMfy9xVjTU2TEIkWVaajqjmwdc9xnc3yByC6dZQjeFmYD3Rvaeu6lct44vBLymxkdT5Po7G6
   b5Li5KWjcBZJ95L6ur1DaBZDTN2E6aVwd+5cQ4zFm4MXhMC6uAssS3+eUK+ZFteDLgkmns+q/Gbt
   5bqJZuixpEhqgM4exLI=
```

This is again a set of key-value pairs, just like the DNS record. It says that the headers in the `h=` (plus the `DKIM-Signature` header itself), combined with the hash of the email body in `bh=`, when signed by the private key that matches the public key at `mandrill._domainkey.petekeen.net`, produce the cryptographic signature in the `b=` field.

(You may be wondering how DKIM can sign a header that includes it's own signature. The answer is that the `b=` field is treated as if it were an empty string when calculating the signature.)

The sending mail server embeds this `DKIM-Signature` header into the message. When a DKIM-compatible mail server receives a message with a signature, it downloads the public key specified in the header and processes the given signature against the message. If they match, the message is authentic. If they don't match, something's wrong. Either way, a new header is attached to the message named `Authentication-Results` that tells servers and spam filters further along how to handle the message.

## Limits

Unlike SPF, DKIM doesn't have a built-in specification for how to handle failing signatures. It's up to each receiving server how to handle it. Some send a bounce message, some just attach the `Authentication-Results` header and let other servers handle it.

DKIM also explicitly doesn't handle what to do when a message has no signature at all. For that, we need another email deliverability record named `DMARC`. See my article [Fix Your Email Deliverability with DMARC](/fix-your-email-deliverability-with-dmarc) for more details on how to handle it.

