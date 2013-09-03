Title: Adventures in Self Publishing
Id:    pub
Tags:  Books
Show_upsell: true

[mmp]: https://www.petekeen.net/mastering-modern-payments
[leanpub]: https://leanpub.com
[nathan]: http://nathanbarry.com
[authority]: http://nathanbarry.com/authority/
[docverter]: http://www.docverter.com
[redcarpet]: https://github.com/vmg/redcarpet
[markdown]: http://daringfireball.net/projects/markdown/
[markdown-mode]: http://jblevins.org/projects/markdown-mode/
[pygments-rb]: https://github.com/tmm1/pygments.rb
[mmp-builder]: https://github.com/peterkeen/mmp-builder
[pdf-template]: https://github.com/peterkeen/mmp-builder/blob/master/template.erb
[mmp-rakefile]: https://github.com/peterkeen/mmp-builder/blob/master/Rakefile
[hn-me]: https://news.ycombinator.com/item?id=6217792
[hn-jstorimer]: https://news.ycombinator.com/item?id=6220724
[/r/rails]: http://www.reddit.com/r/rails
[changelog]: http://thechangelog.com/101/
[ruby-weekly]: http://rubyweekly.com/archive/159.html
[stripe]: https://stripe.com
[rails]: http://rubyonrails.org
[culver]: http://www.andrewculver.net/
[buckbee]: http://www.buzzwordcompliant.net/
 

Three months ago I decided to write my [first technical book][mmp] and it's earned me over $5,000 in the two weeks since launch day, so I thought I decided to share what I've learned.

I had been reading [Nathan Barry][nathan]'s excellent book [Authority][authority] and something about it inspired me. I started throwing around ideas, things that I knew well and that weren't well covered already, and I turned up [Stripe][stripe]. I know Stripe very well having used it for a bunch of projects in the past few years. I also know [Rails][rails], using it in most of those projects plus at my day job. I knew for sure that there were things about payment processing that weren't really talked about much in the 10 minute Stripe tutorials. Thus began my five month journey of writing and self-publishing [Mastering Modern Payments: Using Stripe with Rails][mmp].

--fold--

## Why self publish?

For me, it wasn't even really a question. There's no way a traditional publisher would be interested in a tiny niche topic like this, and even if they were I wanted as much control as I could get for my first major writing project. Not to mention, the amount of money I would get from direct sales is vastly more than I would get from the same number of sales if I were getting royalties.

So, why not something like [Leanpub][leanpub]? Again, it comes down to control. Leanpub provides a valuable service but I wanted to control the entire experience, from building the book files to the landing page all the way through to the sales experience. A great part of the value of the guide is that the Guide + Code edition comes with the code for the application that actually sells the book, and with Leanpub that wouldn't be possible.

## Process and Tools

My writing process is pretty simple. I make an outline, at first just broad themes for chapters or sections. I step back, play with the order a little maybe, and then start adding more detail to the outline. At some point I get bored with that and start filling in chunks with prose. This is the same process I've used for most of my blog posts and it's been pretty successful.

Editing was a much bigger job for the guide than it has been for my blog, of course. I did a first pass by hand on actual paper with an actual red pen and then followed that up with another pass on the computer. Shortly after that I released the guide as preorders to my mailing list (more on that below) and they provided vast quantities of feedback, ranging from typos to bug fixes all the way through to high level feedback on the shape and intent of the guide. I can't thank those reviewers enough. They made it possible to have a polished product on launch day.

The tools I used for most of the writing process:

* **Emacs and Markdown mode**. The book is entirely written in [Markdown][markdown], except for a very few sections written in raw HTML. I use the excellent [Markdown Mode][markdown-mode] for basically everything I write, since it basically just gets everything right.
* **Docverter**. I use Pandoc and Flying Saucer via a local instance of [Docverter][docverter] to build the various formats of the guide.
* **Rake and Redcarpet**. I wrote a few different custom Markdown renderers using [Redcarpet][redcarpet] that do things like highlight code samples with [Pygments][pygments-rb], check the syntax of all of the Ruby code samples, spider all of the links in the book, and finally render out the table of contents how I prefer it.
* **Gimp** for the cover design.

I've [open sourced the code][mmp-builder] that I used to build the book. It's very specific for Mastering Modern Payments and the process that I eventually settled on, but I'm hopeful that it will provide inspiration for others that might be contemplating the same kind of self-publishing venture. It includes the [pdf template and style sheet][pdf-template] I use, along with the [Rakefile][mmp-rakefile] that contains all of the logic for building the guide in it's various formats.

## Preorders

The first thing I did after actually deciding to write MMP was to put up a landing page and start collecting email addresses. On July 15th I started selling preorders, which in this case consisted of 30% off the final purchase price in exchange for an advanced copy of the guide along with regular weekly updates as people sent in feedback. This turns out to have been *highly lucrative* and *extremely motivational*. Preorder sales totaled over $3,000. Dozens of people were interested enough in this project to pay early. If you're developing an info product you should definitely consider some sort of preorder arrangement.

## Numbers

I kept a simple journal throughout the main writing period and adding up all of that I wrote for about 70 hours. The total hours spent on the whole project is probably double that because I didn't count much of the development of the companion Rails application, editing the guide, writing emails to customers, nor of all of the other little tasks that go into a project like this.

As of yesterday, the guide has grossed **$8,603** (this includes preorders):

* **99** copies of Just the Guide for $2,485
* **108** copies of Guide + Code for $5,341
* **3** copies of the Team license for $777

(note that these numbers don't add up to the straight `price * copies` amount because I've had both 10% and 30% discounts going at various times)

<div style="margin-bottom: 2em">
<script type="text/javascript" src="//ajax.googleapis.com/ajax/static/modules/gviz/1.0/chart.js"> {"dataSourceUrl":"//docs.google.com/spreadsheet/tq?key=0AscDwXudwdEhdExnZG9JS0VvbTI3T1pvdFB0R3p3N0E&transpose=0&headers=1&range=A1%3AC101&gid=0&pub=1","options":{"titleTextStyle":{"bold":true,"color":"#000","fontSize":16},"series":{"1":{"color":"#3366cc"},"0":{"color":"#dc3912","targetAxisIndex":1}},"animation":{"duration":500},"backgroundColor":{"fill":"#fcfcfc"},"width":724,"hAxis":{"useFormatFromData":true,"minValue":null,"viewWindowMode":null,"viewWindow":null,"maxValue":null},"vAxes":[{"title":null,"useFormatFromData":true,"minValue":null,"viewWindow":{"min":null,"max":null},"maxValue":null},{"useFormatFromData":true,"minValue":null,"viewWindow":{"min":null,"max":null},"maxValue":null}],"title":"Gross and Page Views by Date","booleanRole":"certainty","height":254,"legend":"top","isStacked":false,"tooltip":{}},"state":{},"view":{"columns":[{"calc":"stringify","type":"string","sourceColumn":0},1,2]},"isDefaultVisualization":true,"chartType":"ColumnChart","chartName":"Chart 1"} </script>
</div>
<div style="margin-bottom: 2em">
<script type="text/javascript" src="//ajax.googleapis.com/ajax/static/modules/gviz/1.0/chart.js"> {"dataSourceUrl":"//docs.google.com/spreadsheet/tq?key=0AscDwXudwdEhdExnZG9JS0VvbTI3T1pvdFB0R3p3N0E&transpose=0&headers=1&range=A1%3AC100&gid=1&pub=1","options":{"titleTextStyle":{"bold":true,"color":"#000","fontSize":16},"vAxes":[{"title":null,"useFormatFromData":true,"minValue":null,"viewWindow":{"min":null,"max":null},"maxValue":null},{"useFormatFromData":true,"minValue":null,"viewWindow":{"min":null,"max":null},"maxValue":null}],"series":{"1":{"targetAxisIndex":1}},"title":"Count and Amount by Product","booleanRole":"certainty","height":307,"animation":{"duration":500},"backgroundColor":{"fill":"#fcfcfc"},"legend":"top","width":648,"hAxis":{"useFormatFromData":true,"minValue":null,"viewWindowMode":null,"viewWindow":null,"maxValue":null},"isStacked":false},"state":{},"view":{},"isDefaultVisualization":true,"chartType":"ColumnChart","chartName":"Chart 2"} </script>
</div>

The biggest driver by far was HN traffic from [two][hn-me] [posts][hn-jstorimer] on launch day, August 15th. The second biggest driver was a link in [Ruby Weekly][ruby-weekly]. I purchased an ad on [/r/rails][] and sponsored [The Changelog][changelog] podcast, neither of which directly generated sales but may have driven direct site visits and sales later on. There wasn't a whole lot of time to put thought into tracking visits from The Changelog so I don't have any direct numbers.

Since launch day the landing page has gotten 6,084 unique page views driving 136 sales for an overall conversion rate of 2.2%. Prior to launch day, the mailing list converted over 30% for preorders.

## Lessons Learned

1. **Get help sooner in the process**

    When I started this project I was all by myself which hampered editing and reviewing a lot. I didn't get my first comprehensive external review of the thing until after I had sold the first few copies. Next time I'll assemble a few reliable technical reviewers ahead of time so that they can start reading drafts before publication.

2. **Write more guest blog posts**

    This is something that Nathan espouses in Authority and I just didn't have time to get to. I only had one guest blog post on launch day and it didn't generate much traffic at all, let alone sales. Next time I'll have at least three lined up, as well as having coverage in the relevant weekly newsletters and podcasts set up beforehand.

3. **Write more relevant content for my email list**

    Early on I was sending interesting little Stripe and Rails things to my mailing list, but after preorders started it became product updates every time. I think at some point I started overselling them. For my next product I'm going to try to alternate product updates with interesting, relevant information that isn't directly related to the product.

4. **Don't have so much going on while developing and selling**

    I had far too many things going on when I decided to launch. Here's an abbreviated schedule for launch day and the following:

    *2013-08-12* &mdash; Start packing for move  
    *2013-08-15* &mdash; Launch day AND travel day on airplanes  
    *2013-08-16* &mdash; Out of internet range, getting things set up   for the wedding  
    *2013-08-17* &mdash; Wedding Day  
    *2013-08-18* &mdash; Travel back to Portland, get ready to move  
    *2013-08-23* &mdash; Pack everything we own and start driving across the country  
    *2013-08-28* &mdash; Attend a funeral  
    *2013-08-29* &mdash; Sign a new lease in Michigan  

    I knew about the wedding and moving well ahead of time, so why did I pick August 15th? Lack of critical thinking, clearly.

## Conclusion

I'd like to take the opportunity to thank my wife, who has put up with not only this project but all of my projects over the last two years. She's the most amazing, understanding person that I've ever met. I'd also like to thank [Michael Buckbee][buckbee], [Andrew Culver][culver], and a whole host of other people who kept me motivated and on track, right to the end.

This project has been an amazing experience. I've learned so much about how to build a product, how to build an audience, and how to make a success, and it's not even over. I'll be releasing periodic updates with corrections and new information since both Stripe and Rails are both active, changing products.

<div class="well" style="margin-top: 2em; margin-bottom: 2em; text-align: center;">
  <h3><small>Sign up to get Rails and Stripe tips as well as guide update notifications (at most once per week)</small></h3>
  <a class="btn btn-primary btn-large" href="/signup">Sign Up for Updates</a>
</div>
