---
title: ASCAP for Open Source Software
id: ascap
---

Mike Perham tweeted earlier today:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Could OSS use an ASCAP royalty model for funding developers? <a href="https://t.co/X2yKO8jYRQ">https://t.co/X2yKO8jYRQ</a></p>&mdash; Mike Perham (@mperham) <a href="https://twitter.com/mperham/status/1004033689267793920?ref_src=twsrc%5Etfw">June 5, 2018</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

[ASCAP](https://en.wikipedia.org/wiki/American_Society_of_Composers,_Authors_and_Publishers) is a voluntary organization in the US (there are others in the US and multiple other organizations internationally) that sublicenses music to radio stations and other public performance places. Music creators register their works with ASCAP, music users pay an annual license fee to ASCAP and report back the music they play, and then ASCAP pays out the majority of that license fee to the creators who's music gets played.

The more I think about it, the more I'm convinced that this is the route we should take as an industry.

Here's how I think it would work. I'm going to refer to this theoretical copyright collective as OSCC (for Open Source Copyright Collective) throughout this document.
It's a terrible name, I know, but we'll think of something better.

## Membership

Membership would be open to anyone who has contributed to a piece of open source software that uses the OSCC license.
Project maintainers would set up a CONTRIBUTORS file listing each contributor and how big of a royalty share they should get.
Candidate membership automatically happens by being listed in a CONTRIBUTORS file, but you'd have to complete membership by setting up an account at the OSCC website.

Package maintainers would need to register their packages with OSCC as well, but that would be a once-per-package thing.

## License and Fees
 
The OSCC license would be a variant of Apache 2.0, BSD, or MIT, with the additional clause that the rights granted by the license are also predicated on paying for annual OSCC license fees.
Fees would be calculated based on some sort of sliding scale based on company size, company type, etc.
Fees would be "all you can eat". I.e., you pay one set fee and you can use as much OSCC-licensed software as you want.
We would need to carefully set things up such that companies don't just license through a penniless subsidiary, but ultimately this is based on good faith backed by a good legal team, just like ASCAP.

## Monitoring

Monitoring would be pretty simple.
Every licensor would upload their Gemfile/package.json/Pipfile/whatever to OSCC at least once a month.
OSCC would comb through the uploaded files looking for registered packages and assign them usage credits based on how big their fee is (the licensor-size).

## Royalties

Packages would earn usage credits.
Each month a package would earn one credit per licensor with a size multipler.
So, a tiny company like egghead would have a size multipler of 1, whereas a big company like Google might have a multipler of 10,000.

We would the calculate the value of a credit by adding up all the credits and all the net monthly OSCC revenue and dividing by the number of credits.

Example: OSCC earns $10,000 for the month after expenses. There are 1,000 total usage credits among all the packages, so one credit is worth $10.
Sidekiq earned 100 credits for the month.
Its total royalty is therefore $1,000 for the month.

## Payout

Package maintainers could split their royalties however they want via the CONTRIBUTORS file.
OSCC would deposit each contributor's share into an internal account at OSCC, and then once the contributor's total account value is greater than $100 they would get a check/direct deposit/wire/PayPal.

---

This is just a really rough proposal. If anyone wants to actually work on this for real send me an email or tweet at me. I'd love to try to get something like this going. It'd be a massive undertaking, but I think ultimately it would be hugely beneficial for the open source community.
