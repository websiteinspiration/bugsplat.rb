---
title: "Email: The Good Parts"
id: email
topic: Email
tags: Email, DNS, _evergreen
description: "There are an awful lot of interesting things happening between hitting Send and your email hitting an inbox. This post is an overview of how your message makes it's way to your recipient."
---

Everybody knows what email is. You click "Compose", fill in the recipient's email address, write your message, maybe give it a pithy subject, and hit "Send". Some time later your recipient opens their email and reads your message. Simple, right?

There are an awful lot of interesting things happening between "Send" and "Some time later". This post is an overview of what happens when you hit "send", and how your message makes its way to your recipient.

## Fundamentals

Under the hood, an email is just a text file. When you send an email, your email client (like Gmail, Mail.app, or Outlook) takes your text, injects some information into "headers" (formatted text before the start of your text), and hands it off to a mail server. Here's an example of a simple composed email:

```text
From: Pete Keen <pete@petekeen.net>
To: Joe Example <joe@example.com>
Date: Sun, 28 Dec 2014 09:52:03 -0600
Subject: This is a simple message

Here's some text in the message. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis interdum in neque sed tincidunt. Nullam sed auctor libero, sed facilisis ligula. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Aliquam sit amet dui a ligula ultrices porta quis vel mi. Nulla ac urna augue. Donec euismod tristique odio eget convallis. Cras ac quam vel sapien pharetra luctus. Aliquam sem eros, auctor non fringilla sed, viverra non turpis. Sed suscipit egestas posuere. In hac habitasse platea dictumst. Nulla facilisi.
```

As you can see, there's really not much to a simple email. Messages can get *far* more complex, with multi-part HTML messages and attachments, but fundamentally they're just formatted text files with headers.

### Mail Transmission

After your client (mail user agent) composes your message it hands it off to a mail server (mail transfer agent), which will hand it to at least one other server at some point before it ultimately ends up in your recipient's inbox. Mail transmission happens via the Simple Message Transport Protocol (SMTP), a simple text-based protocol. Here's a simple SMTP transaction (blue lines with right arrows are what we send *to* the server, black lines with left arrows are what we receive *from* the server):

<pre><code>&larr; 220 web01.bugsplat.info ESMTP Postfix
<span style="color: #3333aa">&rarr; HELO client.bugsplat.info</span>
&larr; 250 web01.bugsplat.info
<span style="color: #3333aa">&rarr; MAIL FROM: test@bugsplat.info</span>
&larr; 250 2.1.0 Ok
<span style="color: #3333aa">&rarr; RCPT TO: pete@bugsplat.info</span>
&larr; 250 2.1.5 Ok
<span style="color: #3333aa">&rarr; DATA</span>
&larr; 354 End data with <CR><LF>.<CR><LF>
<span style="color: #3333aa">&rarr; From: test@bugsplat.info</span>
<span style="color: #3333aa">&rarr; To: pete@bugsplat.info</span>
<span style="color: #3333aa">&rarr; Subject: this is a test</span>
<span style="color: #3333aa">&rarr; </span>
<span style="color: #3333aa">&rarr; Example test.</span>
<span style="color: #3333aa">&rarr; .</span>
&larr; 250 2.0.0 Ok: queued as CD76D606BB
<span style="color: #3333aa">&rarr; QUIT</span>
&larr; 221 2.0.0 Bye
</code></pre>

The transaction starts with an announcment, which we respond to with a `HELO` command specifying who we are. The server replies with its domain name.

Next, we tell the server who the message is from, who it should ultimately be delivered to, then we actually send the message. An important concept here is that the `MAIL FROM` and `RCPT TO` commands are separate from the actual contents of the message and the `From` and `To` headers. They can be completely different. This is actually how the "BCC" function in email is implemented, the addresses that are BCC'd are actually sent the message with their address in `RCPT TO`, but the primary address in the `To` header.

Each time a mail server receives a message it adds a `Received` header with its hostname, the hostname of the machine who sent it, the exact time, and some other information, generally to the top of the stack of headers. Here's the `Received` headers from the message we just sent above:

<pre><code>Received: by <span style="color: #3333aa">10.140.147.132</span> with SMTP id 126csp2632885qht;
        Sun, 28 Dec 2014 09:44:19 -0800 (PST)
Received: from <span style="color: #3333aa">web01.bugsplat.info</span> (<span style="color: #3333aa">web01.bugsplat.info</span>. [192.241.250.244])
        by <span style="color: #3333aa">mx.google.com</span> with ESMTPS id kg1si49786991pad.162.2014.12.28.09.44.17
        for &lt;peter.keen@gmail.com&gt;
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 28 Dec 2014 09:44:18 -0800 (PST)
Received: from <span style="color: #3333aa">client.bugsplat.info</span> (<span style="color: #3333aa">sales02.bugsplat.info</span> [104.131.72.15])
	by <span style="color: #3333aa">web01.bugsplat.info</span> (Postfix) with SMTP id CD76D606BB
	for &lt;pete@bugsplat.info&gt;; Sun, 28 Dec 2014 17:43:19 +0000 (UTC)
</code></pre>

In diagram form, this is what the flow looks like:

![Email Diagram](http://d2s7foagexgnc2.cloudfront.net/files/f64c5bd1293d556e4579/email_diagram.png)

Reading the headers from the bottom (and the diagram from the top), `sales02.bugsplat.info` connected to `web01.bugsplat.info` (lying about who it actually was) and sent a message destined for `pete@bugsplat.info`. `web01` is configured to forward that address to my GMail address, so it connects to Google's mail server and passes along the message using the exact same protocol as shown above. Within GMail there's one more hop to the server that handles my account. Each time an email message is sent from server to server, SMTP is involved.

Lots of other information lives in the headers, including a unique message ID, timestamps, email addresses where you can send complaints, and cryptographic signatures.

You're probably wondering how `web01.bugsplat.info` found the GMail server in the first place. How did it know where to send the message? It looked at the DNS, where Google has set up `MX` (mail exchange) records for the `gmail.com` domain. Here's what those look like:

```bash
$ dig +short gmail.com mx
5 gmail-smtp-in.l.google.com.
10 alt1.gmail-smtp-in.l.google.com.
20 alt2.gmail-smtp-in.l.google.com.
30 alt3.gmail-smtp-in.l.google.com.
40 alt4.gmail-smtp-in.l.google.com.
```

Mail servers are tried in priority order, where the lower number has higher priority. If a receiving mail server doesn't respond the sender will try the next in the list, and if it runs out of servers to try it will hold onto the message for awhile before trying again. You can look up your company's MX records just as easily with the `dig` tool:

```bash
$ dig +short yourdomain.com mx
```

For more information on DNS, check out [DNS: The Good Parts](/dns-the-good-parts).

## Spam

Spam is sort of a nebulous term, but it boils down to unwanted messages. Things you didn't sign up for, don't want, and/or are actively harmful.

Spam has been around for a long time. In fact, the first recognized unwanted message on the internet was sent in 1978, before SMTP was even around (it was an advertisement for a presentation by Digital Equipment Corproation). Since then it's morphed into an actual business model. Drugs, merchandise, insurance offers, and everything else under the sun is advertised via spam messages, sent out by the billions by rogue mail servers. In addition to real (but unwanted) products, the same techniques get used to send out malicious messages like phishing attacks.

The protocol underlying email, named SMTP (Simple Message Transport Protocol) is from a much more civilized era. There's very little sanity checking or verification in the base protocol, which means it's trivial to forge various parts of a message, including headers. If I know your address I can trivially craft a message that, by all outward appearances, looks like it came from you.

## Transactional vs Newsletters

There are two broad swaths of email that businesses send today, other than personal correspondence. Transactional is generally generated in response to events within your application and goes to one person, one at a time.

On the other hand, newsletters are considered "bulk" email. They go from you to a list of people, all at the same time. This doesn't mean they're spam, just that you send a large number of almost-identitcal messages at the same time.

Email service providers distinguish their handling of these different types of messages. For example, spam rules are applied more stringently to messages that they detect as bulk. Depending on the keywords and general format of your messages, GMail might automatically decide to put your bulk email into their "Promotions" tab.

## Trust

Over the years, technologies have come around that help to prevent forgery and help the big providers like Gmail and Yahoo trust your messages, both transactional and newsletters. Those are:

* **SPF**, Sender Policy Framework. Lets the world know what servers are authorized to send mail as your domain.
* **DKIM**, Domain Key Idenitifed Mail. Allows sending email servers to cryptographically sign messages, verifiying that you authorized them to send email as you.
* **DMARC**, Domain-based Message Authentication, Reporting, and Conformance. Specifies a policy for recipient servers, telling them what to do if a message fails SPF or DKIM checks.

I went into these somewhat in [Fix Your Email Deliverability with DMARC](https://www.petekeen.net/fix-your-email-deliverability-with-dmarc). In future posts I'll be taking a deep dive into each one, talking about its history, what its good for, and how to best deploy it.

