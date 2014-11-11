---
title: Building Payola Extensions
id: ext
topic: Stripe
tags: Programming, Stripe
description: How to extend Payola with your own functionality
---

A few weeks ago I [introduced Payola](/introducing-payola), a drop-in Rails engine for setting up Stripe billing. Since that time, it's gained over 400 stars on GitHub and the gem has been downloaded almost 2000 times. The most requested feature, subscripton payments, is well on it's way to being completed.

Payola is more than just a checkout button. It has hooks at various points in the payment flow that let you take action and tie Payola into your application to do things like manipulate the sale object before the charge happens or override the low-level arguments that Payola sends to Stripe. It also has a rich set of notifications when payments complete, fail, or are refunded. In this post, we're going to build a simple extension that sends push notifications when someone buys a product.

There are various third party services that provide push notifications but today we're going to use [Pushover](https://pushover.net), an inexpensive cross-platform personal-use notification system. It's not for big broadcast groups or marketing like Urban Airship or Parse. Instad, Pushover is specifically for our use case: letting your application talk to the developer via push notifications.

**Note:** This article assumes that you've set up Payola in your application already. If you haven't, check out [the Payola docs](https://github.com/peterkeen/payola) for getting started instructions.

## Install Pushover

We're going to use [Rushover](https://github.com/bemurphy/rushover) to integrate with Pushover. It's simple to use and has no big external requirements. Add it to your `Gemfile`:

```ruby
gem 'rushover'
```

and run `bundle install`.

You'll need to [register for an account](https://pushover.net/login) and install the app on your device. It's free to try for five days, and then you'll need to purchase a licence for $4.99.

## The Hook

The specific Payola hook we're going to use is an event named `payola.sale.finished`. Payola fires this event when the sale is complete at Stripe. Internally Payola listens to this event to do things like send automatic emails.

Let's set up the listener in `config/initialzers/payola.rb`:

```ruby
Payola.configure do |config|
  config.subscribe 'payola.sale.finished', lambda do |sale|
    Payola.queue!(PushoverCallback, sale.guid)
  end
end
```

This takes advantage of Payola's built-in job queuing system which integrates with whatever system you have on hand, defaulting to `ActiveJob`'s inline system if it's available. If you want, you could use your queueing system directly.

## The Callback

The code to talk to Pushover is pretty simple. Let's create a file at `app/services/pushover_callback.rb`:

```ruby
class PushoverCallback
  def self.call(guid)
    sale = Payola::Sale.find_by(guid: guid)
    price = sprintf("%0.2f", sale.amount / 100.0)

    client = Rushover::Client.new(ENV['PUSHOVER_API_TOKEN'])

    client.notify(
      ENV['PUSHOVER_USER_TOKEN'],
      "#{sale.email} just bought #{sale.product.name} for #{price}",
      device: ENV['PUSHOVER_DEVICE'],
      sound: 'cashregister'
    )
  end
end
```

From the top, we look up the sale in the database and format the price as something useful. Then, we create a client and call the `notify` method on it. This tells Pushover to send the given message to the user identified by the token. The `device` argument tells Pushover to only send the notification to that specific device and is optional. The other argument, `sound`, lets you pick from a [range of pre-defined options](https://pushover.net/api#sounds). I think the sound an old-school cash register makes is perfectly appropriate, but maybe an alien alarm makes more sense to you.

---

**P.S.**: Payola Pro has pre-built integrations like the example above for Mailchimp and Mixpanel, with many more on the way. It also brings support for Stripe Connect marketplaces, a commercial-friendly license, and priority email support. **[Check it out!](https://www.payola.io/pro)**