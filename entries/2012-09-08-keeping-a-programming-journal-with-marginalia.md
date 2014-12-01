---
title: Keeping a Programming Journal with Marginalia
date: '2012-09-08 08:06:51'
id: 0a99d
tags: Marginalia, Programming
topic: Software
---

In addition to writing on this blog, I've been keeping notes for various
things on [Marginalia](http://www.marginalia.io), my web-based note taking
and journaling app. In my [previous post](/announcing-marginalia)
I talked about the why and how of Marginalia itself. In this post I'd like to talk
more about what I actually use it for day to day, in particular to keep programming journals.

*Update 2013-10-19: Marginalia is shut down and open source [on GitHub](https://github.com/peterkeen/marginalia)*

--fold--

## Programming Journals

I've been keeping programming journals in Marinalia since the beginning, both
for work and home. I've found that having a consistent place to write out my
thoughts on whatever I'm working on to be really valuable, both in the moment
and looking back.

At work we've used various story and issue tracking systems with more or less
decent integration with our source code repository. Currently we use Pivotal Tracker
along with a read-only mirror of our code on Github. Commits referencing stories get appended to the story in Tracker, which is nice for single stories If I'm doing a bunch of stuff in one day it makes it impossible to pull that together to present at daily standup.

To get around this, I write down little snippets of what I'm working on in Marginalia using the "append" feature. Appending to a note or journal is a single API call to `POST /notes/:id/append`. Of course, I don't want to be driving Marginalia with `curl` all the time, so I put together a little Ruby API and example command line program and pushed it to rubygems as [marginalia-io](https://rubygems.org/gems/marginalia-io) ([github](https://github.com/peterkeen/marginalia-io)). Appending with it is really simple. I can either say something like this:

```bash
$ marginalia append 139 I did something just now
```

which would append a timestamp and the text "I did something just now" to note 139. I could also do this:

```bash
$ marginalia append 139
```

which would pop up my editor and let me type a longer form entry. I use this for appending things like SQL queries or longer rants.

## Automatic Entries

In addition to manually adding things that I'm working on, I've added calls to `marginalia append` to various interesting places in my development tools. For example, I have a tool named `git-qa` that does a few interesting things including pushing to various git remotes and deploying to staging servers. I added a simple `marginalia append` to the bottom of this script with the branch that I pushed to QA. Thus, I have an automatic record of what I pushed when that I can look back at, even if I didn't bother to write any actual notes about it. Adding these automatic entries to my tools makes pulling together my daily standup a breeze.

## Project-specific Journals

My work and home programming journals are one big use of Marginalia. The other thing I use it for quite frequenly is to make project-specific journals and todo lists. For example, my todo list for Marginalia itself is over 5KB of text and has over 110 versions. I have a journal for my on-going [Dokuen](/tag/Dokuen) rewrite that has 24 versions and is almost 10KB of text.

## Conclusion

To check out Marginalia, just go to <http://www.marginalia.io> and click the "Try for Free" button. If you register your email address and a password with the free trial you can use the API and command line tool as well. Give it a shot, I think you'll like it.
