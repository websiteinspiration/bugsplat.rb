---
title: Distributed Personal Wiki
id: '83656'
tags: Programming, Git
show_upsell: 'true'
topic: Software
description: Putting together a personal git-backed wiki using Gollum and SparkleShare.
---

For as long as I can remember I've been trying to find a good way to keep personal text notes. Recipes, notes, ideas, that kind of thing. Things that aren't really suited to blogging. Along the way I've used (and stuck with) [PmWiki][], [DocuWiki][], [TiddlyWiki][], and most recently I built my own sort-of-pseudo-wiki [Marginalia][].

Lately, though, it's been kind of a drag to use a web-based application just to write down some work notes. Having sort of an obsession with Markdown I decided to just start keeping notes in Markdown-formatted files in a directory. Of course, files that aren't backed up are likely to disappear at any moment, so I naturally stuck them in a git repository and pushed to my [personal git server][]. But then, how do I deal with synching my work and home machines? I guess I'll manually merge changes...


[PmWiki]:     http://www.pmwiki.org
[Docuwiki]:   https://www.dokuwiki.org/dokuwiki
[TiddlyWiki]: http://tiddlywiki.com
[Marginalia]: https://www.marginalia.com
[personal git server]: /hosting-private-git-repositories-with-gitolite
[SparkleShare]: http://sparkleshare.org
[markdown-mode]: http://jblevins.org/projects/markdown-mode/
[my dotfiles]: /task-oriented-dotfiles
[Gollum]: https://github.com/gollum/gollum
[Mandrill]: http://mandrill.com
[Mailgun]: http://www.mailgun.com

--fold--

Yeah, that lasted about 10 minutes. I had a whole setup baked up that tied together a rake script and an OS X LaunchAgent that watched a directory and everything, but the merging is of course the hardest part.

I went hunting for alternatives. I even briefly considered trying out Evernote, but that didn't really meet with my self-hosting ideals. Dropbox was also a non-starter because, again, not self-hosted. Then I came across [SparkleShare][] and my eyes lit up. SparkleShare uses git as it's transport mechanism, can sync with any git repository, and automatically watches a given directory for changes.

SparkleShare is trivial to set up. Download the package, drag the app to `/Applications`, and run it. It'll create a directory at `~/SparkleShare` and then ask you to add a hosted project. Just create a git repo somewhere (or not, it can sync to any directory that it can talk to via `ssh`), point SparkleShare at it, and you're done. Do this across every machine you want this share on and whenever you add, delete, or modify a file in that directory it'll get synced to all of the other machines automatically.

So, that covers the sync and backup strategy. What about the wiki part? I've been using Emacs [markdown-mode][] for several years to get syntax highlighting when writing blog posts and such, and unbeknownst to me in a recent release Jason added Wiki links and keyboard shortcuts to follow them. I upgraded [my dotfiles][] to the latest version of `markdown-mode` and then bam, wiki in a git repo.

There are two more things that I want to do that would make this system work really well. First, I want to set up [Gollum][] on one of my servers and point it at the git repo that SparkleShare is syncing, so that I can have a web interface and pretty formatting when I want it. The nice thing is that `markdown-mode` and Gollum use the same syntax for wiki links.

Second, I want to replicate the send-an-email-to-create-a-note functionality that Marginalia has. I think I can do this with a tiny CGI script hooked up to [Mandrill][] or [Mailgun][]'s incoming email processing system. All it has to do is drop the message text into the SparkleShare-synced directory with a filename based on the subject.
