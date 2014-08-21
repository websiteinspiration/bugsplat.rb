---
title: 'Fix Your Email Deliverability with DMARC'
id: dmarc
topic: DNS
tags: Programming, Devops
description: Improve your email deliverability using DMARC, SPF, and DKIM.
---

If you do anything more advanced with email than hitting "Send" in Gmail then you should care about *deliverability*, which is the likelyhood that your email will end up in your intended recipient's inbox instead of their spam folder.

In the last few years three technologies have emerged that help you as a sender work with receiving mail servers to ensure that your mail gets where it needs to be. They are

* Sender Policy Framework (SPF)
* DomainKeys Identified Mail (DKIM)
* Domain-based Message Authetication, Reporting, and Conformance (DMARC)

All three of these are implemented using DNS TXT records, so we'll be using the `dig` utility to explore them. If you don't know much about DNS, or just want a refresher, check out my article [DNS: The Good Parts](/dns-the-good-parts). Briefly, a TXT record lets you associate a bit of text with a DNS name. A DNS name can have more than one record associated with it, so you could have one or more A records, an MX record, and one or more TXT records all associated to `example.com`. The one thing you can't do is mix CNAMEs with other types, which I talk about in depth in DNS: The Good Parts.

Together, SPF, DKIM, and DMARC control which servers can send as your domain (SPF), authenticate a message, proving that you sent it (DKIM), and instruct recipients what to do if one or both of those checks fail (DKIM). Combined they're a powerful tool for improving and maintaining your deliverability. Let's dive into each one of them a little.

## SPF

The first technology is [*Sender Policy Framework*](http://www.openspf.org) (SPF). SPF is a way for you to declare the IP addresses or IP ranges that are allowed to send email from your domain. Here's the SPF record for `petekeen.net`:

```bash
$ dig +short petekeen.net txt
"v=spf1 include:_spf.google.com include:spf.mandrillapp.com ~all"
```

SPF is composed of a version followed by one or more declarations. For my domain, I include Google and Mandrill's declarations and then declare everything else as a "soft fail". More specifically, I am telling the world that servers that belong to Google and Mandrill are authorized to send email as me, and everybody else is not, but don't reject it just because they're not authorized.

SPF records can get arbitrarily complicated. The important thing to remember is that they're just a whitelist and/or blacklist of IPs that can or can't send on behalf of your domain.

## DKIM

Another important technology is [*DomainKeys Identified Mail*](http://www.dkim.org) (DKIM). When you send email through a provider that supports DKIM, they will sign the contents of your email and (most of) the headers  using public key cryptography and add that signature as another header. Receiving email servers look up your public key and verify that nothing has changed in the email.

Email service providers have various ways of inserting the key into DNS, but typically you'll add a record at something like `providername._domainkey.example.com` which either contains or points at their key. For example, `petekeen.net` uses Mandrill extensively to send out messages, and Mandrill says to put a DKIM key at `mandrill._domainkey.petekeen.net`:

```bash
$ dig +short mandrill._domainkey.petekeen.net txt
"v=DKIM1\; k=rsa\; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCrLHiExVd55zd/IQ/J/mRwSRMAocV/hMB3jXwaHH36d9NaVynQFYV8NaWi69c1veUtRzGt7yAioXqLj7Z4TeEUoOLgrKsn8YnckGs9i3B3tVFB+Ch/4mPhXWiNfNdynHWBcPcbJ8kjEQ2U8y78dHZj1YeRXXVvWob2OaKynO8/lQIDAQAB\;"
```

As you can see, this follows the same basic format as the SPF record. It contains a version attribute, an attribute that tells it what kind of key it is, and then the actual key itself.

## DMARC

The third technology that helps to ensure delivery is named [*Domain-based Message Authetication, Reporting, and Conformance*](http://www.dmarc.org) (DMARC). DMARC acts as policy statement that declares what to do with emails that fail SPF, DKIM, or both. There are a few different modes that you can use with DMARC, but the most basic one is to receive reports from receiving email servers on pass or fail status. Here's what the DMARC record for `petekeen.net` looks like:

```bash
$ dig +short _dmarc.petekeen.net txt
"v=DMARC1\; p=none\; pct=100\; rua=mailto:re+eVFEGLQ0Ld8@dmarc.postmarkapp.com\; sp=none\; aspf=r\;"
```

The [full standard](https://datatracker.ietf.org/doc/draft-kucherawy-dmarc-base/?include_text=1) goes into what all of these parts mean, but you can interpret this as: report all SPF and DKIM errors to the email address in the `rua` param but continue to accept them.

There are a lot of things you can tweak with your DMARC policy, but the one declared above is the least-impact you can have.

## Monitoring

If you look closely at that DMARC record above, you'll see `dmarc.postmarkapp.com`. Postmark runs a [free DMARC aggregation service](https://dmarc.postmarkapp.com), which will aggregate all of the reports from DMARC-supporting services and send you a report every Monday morning with details. The first step in implementing DMARC is to sign up with Postmark's service, set up the DMARC record that they give you in your DNS, and wait a week.

Yep, a whole week, then come back here and we'll talk about how to handle the inevitable errors that show up in your report.

<div class="well center sans">
<p><strong>Want a reminder to come back in a week?<br> Sign up for the newsletter and I'll send you a note.</strong></p>
  <form action="/subscribe" role="form" method="POST" class="form form-inline" style="margin-top: 0.5em;">
    <div class="form-group">
      <label class="sr-only" for="name">First name</label>
      <input type="text" class="form-control sans" style="font-size: 17.5px; height: 36px; width: 8em; line-height: 22px;" name="name" placeholder="First name"></input>
    </div>
    <div class="form-group">
      <label class="sr-only" for="email">Email address</label>
      <input type="email" class="form-control sans" style="font-size: 17.5px; height: 36px; width: 12em; line-height: 22px;" name="email" placeholder="you@example.com"></input>
    </div>
    <input type="hidden" name="topic" value="dmarc"></input>
    <input type="hidden" name="next" value="/newsletter-dmarc"></input>
    <input class="btn btn-warning btn-large" type="submit" value="Get Updates!" />
  </form>
  <small>We won't send you spam. Unsubscribe at any time.</small>
</div>

<h2 id="howto">How To Fix The Errors</h2>

So you waited a whole week (or just scrolled down, no big deal) and now you have an email from Postmark telling you about all of the problems it found. Now what?

This step is actually pretty easy. For each provider in the list that you know you use, you need to set up SPF and DKIM (if they provide it). Here's a list of common email providers' help documentation on how to do that:

* [MailChimp](http://kb.mailchimp.com/article/authentication-for-mailchimp)
* [Mandrill](http://help.mandrill.com/entries/22030056-how-do-i-add-dns-records-for-my-sending-domains)
* SendGrid ([SPF](https://support.sendgrid.com/hc/en-us/articles/202517236-SPF-Records-Explained), [DKIM](https://sendgrid.com/docs/User_Guide/whitelabel_wizard.html))
* [Mailgun](http://documentation.mailgun.com/quickstart-sending.html#verify-your-domain)
* Amazon AWS SES ([SPF](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/spf.html), [DKIM](http://docs.aws.amazon.com/ses/latest/DeveloperGuide/easy-dkim.html))
* [Google Apps](https://support.google.com/a/answer/178723?hl=en)

You'll probably have to go through this cycle every week for at least a few weeks, in order to catch all of the services that send email as you. Just remember to only add SPF for services that you know about.

**VERY IMPORTANT NOTE** You should only have *one* SPF record for your domain. If you use more than one outgoing email provider, you need to combine their `include` directives together. See the SPF record for `petekeen.net` above for an example of what this looks like.

### What about unknown providers?

Eventually you will likely start to see things in your DMARC report that are suspicious. The most likely cause of this is spammers using your domain to tell everyone they can find about the magic of off-brand C1@LI$. If that starts happening, you can change your DMARC settings to be more strict.

The most complete guide for how to do that is [the standard](https://datatracker.ietf.org/doc/draft-kucherawy-dmarc-base/), since there are quite a few options. That said, if you want receiving email servers to quarantine suspicious messages you can change the `p=` setting from `none` to `quarantine`, or you can change it to `reject` to flat out bounce the messages.

There are a variety of reasons why you wouldn't want to do that, so I advice people to keep their settings at `none` unless they're absolutely sure of the implications for their own domain.
