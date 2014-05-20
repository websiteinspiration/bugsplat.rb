---
title: Self-hosted Git Server
id: sg
tags: Programming
show_upsell: true
topic: Software
description: Moving off of Github and onto my own public Git hosting.
---

I've had a GitHub account since 2008. June 16th, to be exact. For almost six years I've been hosting my code on someone else's servers. It was sure convenient, and free, and I don't regret it one bit, but the time has come to move that vital service in-house.

I've [run my own private git server](/hosting-private-git-repositories-with-gitolite) on the Mac mini in my living room since 2012. For the last few years, then, my GitHub account has become more of a public portfolio and mirror of a selection of my private repos. As of today, my GitHub account is deprecated. If you want to see what I'm working on now you can go to [my Projects page](/projects). I'll be gradually moving old projects over to this page, and new projects will show up there first.

## Implementation

The projects page has three moving pieces. The git repos themselves, read-only public clone access, and finally displaying the projects on the page.

For the git repos, I was able to just re-use the puppet recipe I put together to install Gitolite on my Mac mini. It has a much simpler config because it just needs dynamic repos and no other crazy hooks.

To add read-only clone access I turned to a project named [Grack](https://github.com/schacon/grack). Grack implements git's [smart HTTP protocol](http://git-scm.com/book/en/Git-Internals-Transfer-Protocols#The-Smart-Protocol) as a Rack handler which makes it super simple to add to [bugsplat.rb](/projects/bugsplat), the software that runs this site. Here's what `config.rb` looks like:

```ruby
require 'dotenv'
Dotenv.load

require 'app'
require 'grack'

grack_config = {
  project_root: ENV['PROJECTS_REPOS_ROOT'],
  adapter: Grack::GitAdapter,
  git_path: ENV['GIT_BINARY'],
  upload_pack: true
}

puts grack_config.to_json

use Rack::ShowExceptions
run Rack::URLMap.new \
  '/'       => App.new,
  '/source' => Grack::App.new(grack_config)
```

Every git repo in the directory named by `PROJECTS_REPOS_ROOT` is available for read-only public cloning.

To display these repos, I added a new `Project` class. Here it is, in it's entirety:

```ruby
require 'grit'
require 'yaml'

class Project
  def initialize(path)
    @path = path
    load_config
  end

  def load_config
    data = repo_data(".repo.yml")
    @config = data.nil? ? {} : YAML.load(data)
  end

  def name
    @config['name'] || base_path.gsub('.git', '')
  end

  def description
    @config['description'] || "No description"
  end

  def clone_url
    "https://www.petekeen.net/source/#{base_path}"
  end

  def information_page
    "/projects/#{base_path.gsub('.git', '')}"
  end

  def base_path
    File.basename(@path)
  end

  def repo_data(path)
    repo = Grit::Repo.new(@path)
    obj = repo.tree / path
    if obj
      obj.data.encode('UTF-8')
    else
      nil
    end
  end

  def readme_contents
    repo_data("README.md") || ""
  end

  def self.all
    Dir[File.join(ENV['PROJECTS_REPOS_ROOT'], "*.git")].sort.map do |dir|
      Project.new(dir)
    end
  end

  def self.find(name)
    path = File.join(ENV['PROJECTS_REPOS_ROOT'], "#{name}.git")
    if File.directory?(path)
      Project.new(path)
    else
      nil
    end
  end
end
```

It uses [Grit](https://github.com/mojombo/grit) to pull out the `README.md` file from the repo, as well as a small YAML config file that contains a few pieces of metadata.

The app then uses the existing [Redcarpet](https://github.com/vmg/redcarpet)-based Markdown renderer that renders the rest of the pages and throws the content up on the page.

## Future Additions

There are a lot of little things that this system lacks. Easy code and commit browsing are both huge features that I'd like to add at some point. I thought about using [Gitlab](https://www.gitlab.com/) which has all kinds of nice features, but hacking things together is kind of my thing.

* * * *

I realize that it's a little ironic that most of the links in this post point at GitHub. My reasons for moving to this system are pretty simple: I want to control my own destiny, free of even the possibility that someone else will be able to decide how or what I choose to share with the world.

For a lot of people, GitHub or Bitbucket or another 3rd party service presents a reasonable compromise for them, and that's fine. For myself, today is the last day that I'm pushing new repos to GitHub as well as the last day I'm paying them for my organization account. 
