Title: Marginalia: A web-based journaling and note taking tool
Date:  2012-09-03 17:12:47
Id:    d33f3
Tags:  Heroku, Programming, Marginalia

I'd like to present my new webapp, [Marginalia](https://www.marginalia.io), a web based journaling and note taking tool. Notes are written in [Markdown](https://www.marginalia.io/markdown), and there are some simple shortcuts for appending timestamped entries at the end of a note, as well as a few email-based tools for creating and appending to notes. You should check it out. Look below the fold for technical details and the origin story.

--fold--

## Origin

For a very long time I've had the ridiculous problem of too many ideas. Basically, I would get an idea for something, be it a new app or a tiny implementation detail for work or something. This idea would circle around and around my head for hours, sometimes days, until every single detail was worked out seventeen different ways. Then, satisified, I would promptly forget the entire thing when some *other* idea jumped out of nowhere.

Sometimes I would write these ideas down somewhere. That was great! I could fully hash out whatever it was on paper or in a random file somewhere. Maybe that file would even be in a directory with some code. Except, I would never remember where these papers or files ended up. Still problematic. Over the years I tried various different systems but none of them ever stuck. They were just more silos for me to forget about. The only system that sort of stuck was to email notes to myself.

In January I finally decided to write something that would fit how my brain works instead of trying to change my brain. The result is a Ruby on Rails app named Marginalia (to be completely honest, until Saturday it was creatively named "notes").

## Technical Details

Marginalia is a Ruby on Rails app running on [Heroku](http://www.heroku.com) and Heroku's PostgreSQL database, along with a few addons and libraries:

 * [Memcacheier](http://www.memcachier.com/) for caching
 * [New Relic](http://www.newrelic.com) for error and performance tracking
 * [A/Bingo](http://www.bingocardcreator.com/abingo) for a/b testing
 * [Stripe](http://www.stripe.com) for credit card processing
 * [Mailgun](http://www.mailgun.net) for email processing

I've been living in Marginalia for the last eight months and it's been a *huge* boon to my creativity and memory. I can flesh out ideas using whatever method I want and actually find it later on. If you want to try it out, just go to [the home page](https://www.marginalia.io) and click the "Try for Free" button.

