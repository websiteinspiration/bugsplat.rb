---
title: Why your SaaS application should support SAML
id:    eb452
tags:  Business, Programming
topic: Software
---

Your SaaS application should support SAML (Security Assertion Markup Language) if you're at all interested in big fat contracts from large enterprise customers. And why is that?

One word: money. Large enterprise customers pay *quite a lot of money* for services that help them do their work with a minimum of fuss. They want to do as little management of your service as they can possibly get away with, preferrably zero. If you can't make that happen, but your competitor can, guess who's not getting that big fat contract.

[SAML](https://en.wikipedia.org/wiki/SAML_2.0) is the technology that makes that happen. SAML came out in 2003, long before OpenID and OAuth and JWT and all those other, more modern, hipper authentication protocols. SAML is a stogy old goat based on XML and x509 certificates, which you may be familiar with because that's what SSL uses as well. It's supported by everyone that matters in the enterprise space.

When you set up SAML for your customer you're offloading all of the user management to their centralized system. They crypotgraphically vouch for users that they send your way which means all you have to do is find or create a user account for them and sign them in. No passwords, no email verification, no nothing. It's great for your customer because they get to manage everything on their end. It's great for you because you don't have to deal with any support requests related to passwords or usernames.

In summary: SAML == more money in your pocket.
