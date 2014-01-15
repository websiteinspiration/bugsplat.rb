---
title: Essential Tools for Starting a Rails App in 2013
id: tools
tags: Programming, Rails
show_upsell: 'true'
---

Over the past few years I've written a number of Rails applications. It's become my default "scratch an itch" tool for when I need to build an app quickly to do a task. Even though Rails is mostly batteries-included, there are a few tools that make writing new applications so much easier. This is my list of tools that I use for pretty much every new Rails project.

[dotenv]: https://github.com/bkeepers/dotenv
[devise]: https://github.com/plataformatec/devise
[brakeman]: http://brakemanscanner.org
[rbp]: https://github.com/railsbp/rails_best_practices
[simple_form]: https://github.com/plataformatec/simple_form
[sidekiq]: http://sidekiq.org

*Edit: The discussion on [Hacker News](https://news.ycombinator.com/item?id=6393242) has some great gems that you should consider using as well.*

--fold--

### [Dotenv][dotenv]

[Dotenv][dotenv] is a simple gem that loads environment variables from a file named `.env` in your project root into the `ENV` hash within Ruby. Getting configuration from the environment is one of the factors in [12 Factor Applications](http://12factor.net), and using a `.env` file for development eases the transition to deploying on Heroku. Or, if you're crazy like me, deploying on your own hardware using a nasty brew of Capistrano and Foreman.

### [Devise][devise]

Most Rails apps are going to need a way to authenticate users. You could write something yourself, but there are a lot of subtle security concerns that you have to take into account. By using an off the shelf product like [Devise][devise] you're insulated from having to worry about that. Some people use [AuthLogic](https://github.com/binarylogic/authlogic), which is also perfectly fine.

### [Brakeman][brakeman]

There have been quite a few security vulnerabilities over the past year or so inside Rails, some of which are due to Rails themselves, but many are coding errors or best practices that, over time, have turned out to be not the best. [Brakeman][brakeman] is a security scanner that looks at your code base for both categories of error and tells you if you're doing something wrong. I run Brakeman over my codebase as part of my test suite so I know immediately when I'm doing something that isn't quite right.

### [Rails Best Practices][rbp]

In a simlar vein to Brakeman, [Rails Best Practices][rbp] is a list of best practices that anyone can add to, vote on, and modify. They provide a scanner that looks for violations of these best practices and tells you about them. I also run this as part of my test suite, not because they're necessarily security focused, but hard-won experience has taught me that doing (most of) the things that RBP says to do leads to a more maintainable codebase. They provide a configuration file that you can tweak, in case the scanner starts warning on something that you don't think it should.

### [Simple Form][simple_form]

Much of what we do as Rails developers boils down to making simple CRUD forms to work with models. Much of this is going to be inside an admin interface that users never actually see so we want to get the job done as quickly as possible. [Simple Form][simple_form] lets you write the simplest form declaration possible and bakes in a lot of useful things like error and validation handling. It's also compatible with a number of CSS frameworks like Zurb Foundation and Bootstrap. I tend to use Simple Form in lieu of an admin interface generator like ActiveAdmin, mostly because I haven't had much luck getting those to play with Rails 4.

### [Sidekiq][sidekiq]

At some point every Rails application is going to need to do some background processing, especially if you're making server-side calls to other web services. These should *always* be done outside of a web request because Rule Number 1 is [The network is unreliable](http://en.wikipedia.org/wiki/Fallacies_of_Distributed_Computing) (the PDF in the sources block is a great explanation of the problems of distributed computing, btw). I've explored a number of different background processing systems for Rails and the best that I've found is named [Sidekiq][sidekiq]. It uses less resources per worker than any of the rest and it is super easy to manage.

