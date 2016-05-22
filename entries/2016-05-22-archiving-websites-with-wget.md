---
title: Archiving Websites with Wget
description: How to capture entire websites so you can view them offline or save content before it disappears
id: warc
---

Let's say you want to archive a website. Maybe they're closing down or changing focus, or maybe you just want to view it offline.
You want to capture the whole site at a single point in time. 
How would you do that?

You could just use your browser to save the page, but you probably won't get the HTML or images.
You could print the page to a PDF, but then it's in a weird format and might be stuck in the print stylesheet forever.

You could use a service like [Pinboard](https://pinboard.in) but they only archive one page, whereas you want to capture the whole site.

So, what do you do?

***

If you've used the internet for awhile you probably know of a little website called the [Wayback Machine](https://archive.org/web/). 
The Wayback Machine, as it's name implies, lets you travel back in time and view websites as they existed at various points in the past.

This fantastic machine is run by an organization called the [Internet Archive](https://archive.org/), a non-profit that has the noble mission of preserving the entire Internet, along with things like movies, old video games, music, etc.

When IA first started doing their thing, they came across a problem: how do you actually save all of the information related to a website as it existed at a point in time? IA wanted to capture it all, including headers, images, stylesheets, etc.

After a lot of revision the smart folks there built a specification for a file format named `WARC`, for Web ARCive.
The details aren't super important, but the gist is that it will preserve everything, including headers, in a verifiable, indexed, checksumed format.

## Capturing Archives

What does this have to do with our problem?
It turns out that you can produce your own `WARC` files using a tool you already have on your Mac OS X and/or Linux machine!
Just open up a terminal and type something like this:


```bash
$ wget \
    --mirror \
    --warc-file=YOUR_FILENAME \
    --warc-cdx \
    --page-requisites \
    --html-extension \
    --convert-links \
    --execute robots=off \
    --directory-prefix=. \
    --span-hosts \
    --domains=example.com,www.example.com,cdn.example.com \
    --user-agent=Mozilla (mailto:archiver@petekeen.net)\
    --wait=10 \
    --random-wait \
    http://www.example.com
```

Let's go through those options:

* `wget` is the tool were using
* `--mirror` turns on a bunch of options appropriate for mirroring a whole website
* `--warc-file` turns on `WARC` output to the specified file
* `--warc-cdx` tells `wget` to dump out an index file for our new `WARC` file
* `--page-requisites` will grab all of the linked resources necessary to render the page (images, css, javascript, etc)
* `--html-extension` appends `.html` to the files when appropriate
* `--convert-links` will turn links into local links as appropriate
* `--execute robots=off` turns off `wget`'s automatic `robots.txt` checking
* `--span-hosts` allows it to follow links to other domain names
* `--domains` includes a comma-separated list of domains that `wget` should include in the archive
* `--user-agent` overrides `wget`'s default user agent
* `--wait` tells `wget` to wait ten seconds between each request
* `--random-wait` will randomize that wait to between 5 and 15 seconds
* `http://www.example.com` is the website we want to archive

Two of the options need some explanation.
First, disabling robots checking is not normally something you should do because it's not very polite, but I'm assuming you're going to be grabbing these archives for personal use only so turning this off is acceptable.

Second, we override `wget`'s default user agent to include `Mozilla` so servers don't reject us outright. More importantly we add an email address so site owners can contact us if we're causing problems.

Third, adding a wait time between requests reduces load on the server you're accessing.
You should be polite to the people that own the website you're archiving.

## Browsing Archives

If you just grab HTML pages and stick them in a folder somewhere, you can just double click on them and view them in your browser.
Not so much with a `WARC` file.

I use a simple tool named [Web Archive Player](https://github.com/ikreymer/webarchiveplayer) to view the archives I've created.
Just download the tool and run the application.
It will prompt you for a `warc` file to open, and when you pick one it will open up your browser automatically so you can navigate your archive.

***

A few notes before you start archiving everything:

1. This is for personal use only! Don't start infringing copyright by publishing archives against publishers' wishes.
2. Always be polite! Use the wait option. Use a user agent that identifies who you are.
3. This works for sites that are mostly static HTML. It's not going to work for YouTube, Twitter, Facebook, etc that have videos or use Javascript to load things.
