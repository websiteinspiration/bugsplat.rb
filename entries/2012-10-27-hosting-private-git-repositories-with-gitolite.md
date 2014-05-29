---
title: Private Git Repositories with Gitolite and S3
date: '2012-10-27 15:59:41'
id: aa310
tags: Git, Programming
---

Earlier this year I bought a new Mac mini for various reasons. One of the big ones was so I would
have a place to stash private git repositories that I didn't want to host on 3rd party services
like Github or Bitbucket. This post describes how I set up [Gitolite][gitolite] and [my own hook scripts][git-hooks],
including how I mirror my git repos on S3 using [JGit][jgit].

[gitolite]: https://github.com/sitaramc/gitolite
[jgit]: http://eclipse.org/jgit/
[git-hooks]: https://github.com/peterkeen/git-hooks

--fold--

## Step 1: Install Gitolite

[Gitolite][gitolite] is a system for managing git repositories using git itself to manage the configuration.
Essentially, after initial configuration you make all changes by editing a config file, committing
it, and pushing up to your git server.

Gitolite installation is pretty straightforward:

1. Install git on your server. On a Mac the easist way is to use Homebrew. On Ubuntu or Debian
   you would `apt-get install git-core`. Redhat systems are similar.
1. Create a user named `git`
2. Login as the `git` user
3. Remove any existing `authorized_keys` file
4. Put your public key in a file named `your_name.pub`. Mine is called `pete.pub`.
5. Ensure `~/bin` is in your `PATH`
5. Run these commands in the `git` user's home directory:

     ```bash
     $ git clone git://github.com/sitaramc/gitolite
     $ mkdir -p $HOME/bin
     $ gitolite/install -to $HOME/bin
     $ gitolite setup -pk YourName.pub
     ```

6. Move to your workstation and run this command:

     ```bash
     $ git clone git@your_server:gitolite-admin
     ```
     
If everything has gone well you'll be able to clone that repo without being asked for a password.
There are a *ton* of things you can do with Gitolite and I don't have room to get into it here. Check
out the [README][gitolite-readme] on Github and the [extensive documentation][gitolite-docs] for more
instructions and details on how exactly Gitolite processes things.

## Step 2: Write some hooks

Well, not really. You can use [mine][git-hooks] if you want, if they suit your goals. I wanted to
hit a few different areas with my git server:

#### Simple, flexible mirroring and backups

One of the big things that I was paying Github for was to serve as an off-site repository backup.
If for some reason I lost my laptop, my various projects and businesses would be safe because the
code was also at Github. But what if I could just push to S3? Amazon S3 is far more cost effective
if all you need is a place to shove files, and it so happens that the [JGit project][jgit] lets you use
an S3 bucket as a remote.

#### Simple to use pre- and post-receive hooks

My hook scripts let you set up a pre- or post-receive hook directly in your Gitolite config with
an optional branch filter regex.

#### Local clones

One of the other things I do with my Mac mini is run a customized reporting application on top of
my Ledger file, which contains close to six years of personal finance data. The reporting application
runs on top of a postgresql database which I load with the combination of a local clone
of my finances repo and a post-receive hook that starts the dump and load.

### Hook Installation

So those are my hooks. If you want to use them, clone the [repo][git-hooks] onto your server and copy or symlink
`pre-receive` and `post-receive` into `$GITUSER_HOME/.gitolite/hooks/common/` and `jgit` into
`$GITUSER_HOME/bin`.

You'll also need to modify your `$GITUSER_HOME/.gitolite.rc` file slightly. Add these lines somewhere
toward the top of the `%RC` hash:

```perl
GIT_CONFIG   => '.*',
AUTH_OPTIONS => 'no-port-forwarding,no-X11-forwarding,no-pty',
```

The first line allows the config file to contain any git config options you want. The second removes
the agent forwarding restriction. The default includes `no-agent-forwarding`.

If you want to push to S3 buckets, you'll need to create a file named `.jgit` in the `git` user's
home directory with these contents:

```yaml
accesskey: YOUR-AWS-ACCESS-KEY
secretkey: YOUR-AWS-SECRET-KEY
```

S3 mirror URLs follow the format `amazon-s3://<filename>@<s3-bucket-name>/<repo_name>.git`. See below
for an example.

## Step 3: Profit

Here's my gitolite config after installing my hooks:

```text
repo @all
    config mirrors.s3 = "amazon-s3://.jgit@my-s3-bucket/REPO_NAME"

repo gitolite-admin
    RW+     =   peter

repo CREATOR/[a-zA-Z0-9].*
    C = @all
    RW+ = CREATOR
    RW = WRITERS
    R = READERS gitweb

repo apps/[a-zA-Z0-9].*
    C                   = @all
    RW+                 = CREATOR
    config hooks.pre    = '/usr/local/var/dokuen/bin/dokuen-deploy'

repo financials-master
    RW+ = peter
    config hooks.clone.path = "/usr/local/var/repos/financials"
    config hooks.post = "sudo -u peter /usr/local/var/dokuen/bin/dokuen run_command rake load --application=ledger"

repo peter/git-hooks
    config mirrors.github = "git@github.com:peterkeen/git-hooks.git"

repo peter/bugsplat
    config mirrors.github = "git@github.com:peterkeen/bugsplat.rb"
    config mirrors.heroku = "git@heroku.com:bugsplat.git"
```

At the top, every repo gets transparently mirrored to my S3 bucket. `REPO_NAME` gets
replaced with the actual path of the repo. After some boilerplate about the `gitolite-admin`
repo comes the meat of the config. I use a gitolite feature called [Wild Repos][gitolite-wild-repos] which will
automatically create a repo matching the pattern (in this case `CREATOR/[a-zA-Z0-9].*`) the
first time I push to it. The `apps` entry is the exact same idea with the addition of a
pre-commit hook that fires off my Dokuen deploy script.

I described the `financials-master` repo earlier. After that is some additional config
for a few auto-created repos. Gitolite stacks your configurations together which is what
lets me get away with only specifiying the mirror config. Everything else is in the
wild repo definiton.

## Conclusion

Running a private git server probably isn't for everyone but for me, it allows me to have
a huge amount of flexibility in how I set up my repos. It's also been basically maintenance
free with the exception of some small config changes here and there.

[gitolite-wiki]: https://github.com/sitaramc/gitolite/wiki
[gitolite-wild-repos]: http://sitaramc.github.com/gitolite/wild.html
[gitolite-docs]: http://sitaramc.github.com/gitolite/master-toc.html
[gitolite-readme]: https://github.com/sitaramc/gitolite#readme

