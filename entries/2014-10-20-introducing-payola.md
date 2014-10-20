---
title: Introducing Payola
id: payola
topic: Stripe
tags: Programming, Stripe
description: A drop-in Rails engine for accepting credit card payments with Stripe
show_upsell: true
---

I released an open source Rails engine named [Payola](http://www.payola.io) that you can drop into any application to have robust, reliable self-hosted Stripe payments up and running with just a little bit of fuss.

When you're setting up Stripe in a Rails application there are a lot of choices you have to make. *What should you use for webhooks? Do you even need webhooks? How much information should you keep in your database? Should you use Checkout or do you need to design your own form?* Amongst all of these choices, you also have to decide what libraries you want to use, and boy howdy are there even *more* options here. [Koudoku](http://koudoku.org), [StripeEvent](https://github.com/integrallis/stripe_event), [Stripe::Rails](https://github.com/thefrontside/stripe-rails), not to mention commercial options like [Gumroad](https://gumroad.com), [Plasso](https://plasso.co), and [Cargo](http://cargocollective.com).

One of the reasons why I wrote my book [Mastering Modern Payments: Using Stripe with Rails](https://www.masteringmodernpayments.com) is to help you narrow down that set of choices to something reasonable, and I think it does a very good job of it. That said, even if you're using my book you still have to actually write the code to implement Stripe. Not that it's a lot of code, but it's basically always the same.

For the recent relaunch of MMP I decided to actually sit down and formalize the "hows" laid out in the book into a Rails engine. Anyone can drop Payola into an application and have payments going without too much drama, and notably none of the choices outlined above.

## What Payola Does

Payola provides a complete solution for accepting Stripe payments within a Rails application. It is focused on selling items one at a time and includes a drop-in partial for setting up a [Stripe Checkout](https://stripe.com/checkout) button, along with a complete server-side asynchronous processing system for completing payments with Stripe.

To see a demo, click on or inspect one of the buttons in the [Packages section on the MMP website](https://www.masteringmodernpayments.com).

## Design

I designed Payola to be robust in the face of failure, whether that means network failure, bugs, Stripe API slowness, or anything in between. It consists of a few moving pieces:

* User-facing Javascript that gets a token from Stripe and sends it, along with other Payment-related information, to the backend.
* An async backend that uses a state machine to track a payment through every stage.
* Integration with your application via a model concern and ActiveSupport notifications when interesting things happen.

Payola has built-in support for [Sidekiq](https://sidekiq.org) and [Sucker Punch](https://github.com/brandonhilkert/sucker_punch), but it's easy to add new backend worker systems which makes it even easier to adapt to your current system.

Payola should also be transparent to your customers. There should never be a time when they actually see a Payola URL in their address bar, nor should they ever see something Payola branded. From a buyer's perspective it should be *your* site selling the product, not Payola.

## How A Click Becomes A Charge

Here are all of the steps in a successful charge:

1. Buyer clicks a checkout button, which spawns a Stripe Checkout lightbox.
2. Buyer enters their card information and clicks the Pay button.
3. Stripe validates their card information and creates a token.
4. Token is passed the Payola's javascript, which in turn POSTs it to the backend.
5. Payola creates a `Payola::Sale` object with the token and sets it to `pending` state.
6. Payola queues a background job to create a Stripe charge for the corresponding sale and passes the sale's `guid` attribute back to the JS.
7. The buyer's browser disables the button and polls Payola every 500ms asking for the state of their charge.
8. The background job calls the `Payola.charge_verifier` callback, then creates the charge with Stripe, then sends the `payola.<product>.sale.finished` notification to your application.
9. The background job finally sets the sale's state to `finished`, which is picked up by the JS.
10. The user's browser redirects to `/payola/confirm/<guid>` and then is immediately redirected to whatever the product's `redirect_url` returns, defaulting to `/`.

A charge will typically fail in the background job (step 8), either because the `charge_verifier` rejects it or Stripe rejects it. In that case, the sale is set to `errored`, the error message is set in the `error` column, and the Payola JS shows it in a (customizable) `div` after re-enabling the button. Your application will also receive a `payola.<product>.sale.errored` notification.

## Installation

Installing Payola in your app is just a few steps. First, add the gem:

```ruby
gem 'payola-payments'
```

Then, run the installer and install the migrations:

```bash
$ rails g payola:install
$ rake db:migrate
```

Next add the `Payola::Sellable` concern to the models you want to sell:

```ruby
class SomeProduct < ActiveRecord::Base
  include Payola::Sellable
end
```

Your model needs three attributes:

* `permalink`: a unique, human readable name
* `name`: a short description
* `price`: the price for the sellable in whatever format Stripe expects. For USD this is cents, for other currencies it could be different.

By default Payola will use USD but you can change that by adding an optional `currency` method to your sellable model. This can either be a fixed method if you're only using one currency, or it can be a column in the database if your products come in multiple currencies.

Optionally, you can provide a method named `redirect_path`. This method takes a `Payola::Sale` instance and returns a path where Payola should redirect the browser after a successful purchase. If you don't provide this Payola will redirect to '/'.

Finally, use the `checkout` partial to render a checkout button:

```rhtml
<%= render 'payola/transactions/checkout',
    sellable: SomeProduct.first %>
```

While the `checkout` partial has reasonable defaults for getting off the ground, you can customize basically every aspect of it. See the [documentation](https://github.com/peterkeen/payola#checkout-button) for details.

## Event Handling

Stripe has excellent support for webhook events and the StripeEvent gem does an excellent job handling them. Payola thinly wraps StripeEvent and adds a bit of behavior. To receive events, just set up a webhook url in your [Stripe account settings](https://dashboard.stripe.com/account/webhooks) that points at `https://www.example.com/payola/events`. Then, configure an event listener in `config/initializers/payola.rb`:

```ruby
Payola.configure do |config|
  config.subscribe 'charge.succeeded' do |event|
    puts "whoohoo!"
  end
end
```

Payola adds deduplification to StripeEvent. It records every `event_id` that comes in and will only ever process an event once. If you'd like to further filter events, you can set `event_filter`, which should either return a `Stripe::Event` or `nil` if you'd like to stop processing.

In addition to Stripe's webhooks, you can listen for three special events:

* `payola.<underscored product class>.payment.finished`
* `payola.<underscored product class>.payment.failed`
* `payola.<underscored product class>.payment.refunded`

These are invoked with the corresponding `Payola::Sale`, not a `Stripe::Event` and are executed in-line with the async processing chain, which means you can do things like create a user or send an email before the user-facing javascript returns.

## What's Next

Currently Payola does not handle subscriptions or marketplaces, so those will be next on the list. Along with those I'll be adding support for custom forms instead of the Checkout button. I'm also planning on building out a Pro version that will include priority support and a bunch of pre-built integrations for external systems like Mailchimp, Mixpanel, Infusionsoft, and more.

Here's some more links to Payola stuff:

* [Payola GitHub](https://github.com/peterkeen/payola)
* [Submit an issue for bug reports or feature requests](https://github.com/peterkeen/payola/issues)

[Send me an email](mailto:hi@petekeen.net?subject=Payola) if you'd like to talk about Payola or Payola Pro.
