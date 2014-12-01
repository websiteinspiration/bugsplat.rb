---
title: Command Line Faxing
id: clifax
tags: Programming
topic: Software
description: The fax machine is an archaic technology. Let's mash it up with another one!
---

When I started [my little side consultancy](/consulting) I had to fax in some forms to the State of Michigan. The entire system for opening businesses in Michigan, in fact, is basically a [fax driven API](https://www.michigan.gov/lara/0,4601,7-154-35299_61343_35413-135307--,00.html). Being a modern, hip millenial I don't subscribe to a land line phone, nor do I own a fax machine. How was I supposed to fax things?

Enter [Phaxio](https://www.phaxio.com). They have a whole bunch of fax machines (actually they're probably [banks of modems](http://en.wikipedia.org/wiki/Modem#mediaviewer/File:Modem-bank-1.jpg)) in a data center somewhere and they let you use them with a [simple HTTP API](http://www.phaxio.com/docs/). All you have to do is go sign up and make an initial deposit. They'll provide you with an API key and secret pair that you can then use to send faxes using `curl`.

--fold--

For a time I was actually hand-writing the `curl` commands. That got tedious and annoying so I wrote up this little script:

```ruby
#!/usr/bin/env ruby

unless ARGV.length >= 2
  STDERR.puts "Usage: send_fax NUMBER FILENAME..."
  exit 1
end

number = ARGV.shift
api_key = ENV['PHAXIO_API_KEY']
api_secret = ENV['PHAXIO_API_SECRET']

command_args = [
  'curl',
  'https://api.phaxio.com/v1/send',
  "-F to=#{number}",
  "-F api_key=#{api_key}",
  "-F api_secret=#{api_secret}"
]

ARGV.each do |file|
  command_args << "-F filename[]=@#{file}"
end

exec command_args.join(" ")
```

All this does is grab my keys from the environment, sanity check the arguments, and construct and execute the curl command I was writing. It's as simple as that.

Like any good FaaS (facimile-as-a-service), Phaxio can be configured to send out webhooks when faxes come in or go out. The thing that really sets Phaxio apart in my mind is that you can set your webhook URLs to be `mailto:` URLs (ex. `mailto:faxes@example.com`), which means you don't have to set up an application for notifications. The emails come with handy links to download your faxes in one click.

## How much does this cost?

Well, it's not free but [it's practically free](https://www.phaxio.com/pricing). Pages are 7 cents a pop and incoming numbers (which are totally optional unless you want to receive faxes) cost $2 per month. Michigan's ELF system automatically faxes you status updates and documents (would these be "faxhooks"?) so I have an incoming number.

## What about signatures?

Ah yes. The reason why you'd need to send a fax in the first place instead of emailing things around is because your documents contain sensitive information and probably have to be signed. OS X's Preview application has a super handy feature built in named "Signature Capture". Just open up the PDF you need to sign, then go Tools -> Annotate -> Signature -> Create Signature from FaceTime HD Camera, which will open up a little dialog box like this:

![Signature Capture](http://d2s7foagexgnc2.cloudfront.net/files/484d28b8d0ca571d68ee/signature_capture-2.png)

Just sign your name onto a blank sheet of paper, hold it up to your camera, and then hit "Accept". Then your signature will be available within the same "Signature" submenu. Select it, click anywhere in a document, and *poof* you just signed it.

I've been using this system for about six months to sign and fax documents for things like opening bank accounts, setting up my company, and signing contracts. There are probably better systems out there. What's yours?
