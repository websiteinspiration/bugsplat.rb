---
title: Post-mortem of a Dead-on-Arrival SaaS Product
id: doa
tags: Marginalia, Programming
---

A little over a year ago I [announced the launch](/announcing-marginalia) of my latest (at the time) product named Marginalia. The idea was to be a sort of online journal. A cheaper, more programmer friendly alternative to Evernote. It never took off, despite my best intentions, and so a few months ago I told the only active user that I was going to shut it down, and today I finally took that sad action. This post is a short history of the project and a few lessons learned.

--fold--

## A Brief History

<img src="https://d2s7foagexgnc2.cloudfront.net/files/e36d73e5075e0eb8456f/create_note.png">

Marginalia actually started out pretty humbly. See, for a very long time I've been emailing ideas to myself and then forgetting that I did that and thus those ideas were just completely lost. I needed a better way to capture all of this so I could get it out of my head and into something more permanent. In late January 2012 I finally put together a simple Rails application that used a [Mailgun](http://www.mailgun.com) incoming account to parse emails sent to a special address and add the Markdown-formatted body content to a new page. The app would reply to that email with the `From:` address set to a unique address. Anything emailed to that address would get appended to the note with a timestamp.

I used this simple app called "Ideas" for seven months and loved it to pieces. I captured a lot of ideas in there, along with daily work notes and other various things. At some point I started talking about it with other people and they encouraged me to try selling it, and after a lot of consideration I added subscriptions and billing and all of the other little things a real SaaS app needs. Then I wrote a blog post and got it on the front page of HN briefly, and then... nothing. A few signups for the original "pay once" subscription model, a handful of people signing up for the $5/mo plan and then never coming back, and otherwise no other traffic. I kept using it for awhile and then [built a better mousetrap](/git-backed-personal-markdown-wiki) and moved on.

## Lessons Learned

**People want their privacy.** I originally tried pitching Marginalia as a way to keep a programming journal, which ended up being a losing proposition. First of all, software developers don't want to spend money on tools when their free or already-paid-for editor is just as good. Second, keeping journals of any kind at an external service is something that most developers are not at all into because of the privacy implications.

**Itched scratches frequently bleed money.** Every month Heroku charged me $29 for SSL and a non-development-level database. Every month for more than a year, with zero income. It's not a lot of money but it's money from my web hosting budget that could have been going toward something more productive. I also spent an *awful* lot of money on paid advertising trying to get an audience with zero return.

**Launching without an audience means nobody shows up.** Building a product without an excited, engaged audience is one of those things that software developers tend to do, often and with gusto. It's so easy to build up this idea in your head and in your editor and just expect people to show up after you're done. It's something that I've done three times and it's something I will hopefully never repeat. For my [latest product](/mastering-modern-payments) I started with a simple landing page with a Mailchimp signup form. Only after actually determining interest did I move forward with the plan.

## Conclusion

The source is [up on GitHub](https://github.com/peterkeen/marginalia) if you want to take a look at how it came together. There's some features, including on-page javascript evaluation and data blocks, that never got announced but which I still think were a good idea.
