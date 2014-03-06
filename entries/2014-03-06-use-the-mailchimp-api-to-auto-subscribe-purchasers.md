---
title: Using the Mailchimp API for Sales
id: mc
tags: Programming, Marketing
show_upsell: true
---

One of the very first things I did when I started working on the idea that eventually became [Mastering Modern Payments](/mastering-modern-payments) was set up a [Mailchimp](http://mailchimp.com) mailing list. People would land on the teaser page and add themselves to the list so that when the book came out they would get a little note. After the book launch ([with 30% of that initial list eventually buying](https://www.petekeen.net/adventures-in-self-publishing)) I started putting actual purchasers on the list.

For three whole months my process was:

1. Use a rake task to export the entire list as a CSV
2. Navigate to Mailchimp
3. Remind myself where the import button is and click it
4. Paste in the CSV
5. Assign field labels
6. Hit the "import" button
7. Wait for an email saying it was done

I did this *every single time* I sent an email to the list, which was quite often when I was actively fixing bugs in the book. Clearly this couldn't continue.

Mailchimp turns out to have a [very nice API](http://apidocs.mailchimp.com/api/2.0/) these days and there's a [plethora of good libraries out there](http://apidocs.mailchimp.com/api/downloads/) to help you take advantage. Because the Mastering Modern Payments application is written in Ruby I chose to go with [Gibbon](https://github.com/amro/gibbon).

The code is remarkably straight forward:

```ruby
class MailchimpWorker
  include Sidekiq::Worker

  def perform(guid)
    ActiveRecord::Base.connection_pool.with_connection do
      sale = Sale.find_by(guid: guid)

      gb = Gibbon::API.new

      gb.lists.subscribe(
        id: Rails.configuration.mailchimp[:list_id],
        update_existing: true,
        email: {email: sale.email},
        merge_vars: {
          PRODUCT: sale.product.permalink,
          PURCH: 't',
          GUID: sale.guid,
          AMOUNT: sale.amount,
          PURCHAT: sale.created_at.strftime('%Y-%m-%d %H:%M:%S')
        }
      )
    end
  end
end
```

To start out, it's a [Sidekiq](http://sidekiq.org/) worker. Every customer-initiated interaction with Stripe and Mailchimp in the MMP sales app goes through Sidekiq. Feel free to substitute Sidekiq for whatever other background worker you use, or if you're feeling cheeky just don't use one at all.

Then it goes on to look up the sale, build a new instance of the Gibbon API, and call the `subscribe` method. Three things to note here. First, the `update_existing` flag. I don't want to stomp on the user's record if it exists, I just want to update it with their sales info.

Second, the `merge_vars` keys are in all caps. Mailchimp merge vars are *case sensitive*, in so far as they are always upper case. If you specify the wrong merge vars nothing will happen, the update will just silently fail (I spent probably two hours debugging that one).

Third, that `PURCH` merge var. This list is a mixture of people who are possibly interested in buying the book and also people who have definitely purchased the book. Frequently I'll want to send to either of those groups, but not both, and Mailchimp's search interface makes it surprisingly difficult (impossible, actually) to check for null values. Instead, I set this little true/false flag and then I can do a search for `purchased == 't'` or `purchased != 't'`.

The Sidekiq job that processes the sale with Stripe kicks this job off as the very last step in the process. I can instead sit back with a bottle of beer and write emails to the list, confident in the knowledge that everyone who should get an email will.
