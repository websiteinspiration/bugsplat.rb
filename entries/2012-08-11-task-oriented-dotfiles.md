---
title: Task-oriented Dotfiles
date: '2012-08-11 20:38:36'
id: 144c7
tags: Programming
---

Recently I sat down and reorganized [my dotfiles][dotfiles] around the tasks that I do day-to-day. For example, I have bits of configuration related to [ledger][] and some other bits related to Ruby development. In my previous dotfile setup, this stuff was all mixed together in the same files. I had started to use site-specific profiles (i.e. home vs work), but that led to a lot of copied config splattered all over. I wanted my dotfiles more organized and modifiable than that.

[dotfiles]: https://github.com/peterkeen/dotfiles/
[ledger]: /ledger
[Zach Holman]: http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/
[Ryan Bates]: https://github.com/ryanb/dotfiles
[emacs]: https://github.com/peterkeen/dotfiles/blob/master/core/emacs.symlink
[bash]: https://github.com/peterkeen/dotfiles/blob/master/core/bashrc.symlink
[el-get]: https://github.com/dimitri/el-get/

--fold--

I borrowed the basic ideas from [Zach Holman][], who borrowed them from [Ryan Bates][]. In fact, I stole their Rakefile and only made a few minor additions. Essentially, each *module*", where a module is a unit of config related to a single task, has it's own directory in my [dotfiles repository][dotfiles]. This directory can contain any number of files with names like `foo.symlink`. This will get symlinked to `~/.foo`. In addition, each module can contain a `init.sh` and `init.el` file. These get loaded by `bash` and `emacs`, respecively, at runtime. The [emacs initialization code][emacs] contains a bunch of clever things that allow me to require external emacs packages using [el-get][], as well as run code before and after `el-get` packages get initialized. The [bash initialization code][bash] contains no such cleverness (yet). Each module can also contain a `bin` directory, which will get added to `$PATH`.

So, this is great, but what if I don't want to load my `ledger` configuration on my work computer? Or what if I have some work-specific module that I don't want to be loaded at home? That's where the `~/.modules` file comes in. This file lists the modules that `bash` and `emacs` will load, in order. This file is not checked in, because it can and will be different between machines.

One other interesting thing I've done is set up an auto-update system. I have `cron` set to run a `git fetch` every minute or so, and then I have my `bash` prompt set to inform me if there are updates available or if the dotfiles repo is dirty. I don't have a one-button command to apply the updates yet, but it's something I'm considering.

I owe [Zach Holman][] a lot of credit here, but I think I've improved upon the initial design, at least for my needs, with the explicit modules list and the `$PATH` manipulation. I expect that my particular implementation won't be very useful for anyone else, but if you'd like to use it for inspiration, the `Rakefile` would probably be the easiest thing to copy.
