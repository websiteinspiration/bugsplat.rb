---
title: Handling events with StripeEvent
id: blasdfasdf
---

Hey there,

Thanks for subscribing to the Stripe Rails email course. Here's an outline of what to expect over the next few days:

1. How to handle Stripe webhook events with a library named `stripe_event`
2. How to test your Stripe integration with Stripe Mock
3. Processing payments using background workers
4. A sample chapter from my book Mastering Modern Payments.
5. Wrap up

So, without further ado, here's one way to handle Stripe's webhook events.

The library I'm going to talk about does a great job at exactly one thing: handling Stripe webhook events. It's called, interestingly enough, [StripeEvent](https://github.com/integrallis/stripe_event). It's a rack middleware that sits inside your application and lets Stripe tell your application about interesting things, like people paying you.

The first thing to do, as always, is to add it to your `Gemfile`:

```ruby
gem 'stripe_event'
```

Run `bundle` and then create an initializer at `config/initializers/stripe_event.rb`:

```ruby
StripeEvent.configure do |events|
  events.subscribe 'charge.succeeded', ChargeSucceeded.new
end
```

This sets up a handler for `charge.succeeded` that points at a class named `ChargeSucceeded`. Every time Stripe sends that event to our application, StripeEvent will invoke the `call` method on the instance of `ChargeSucceeded` that you created.

So, now let's create that class, in `app/stripe_handlers/charge_succeeded.rb`:

```ruby
class ChargeSucceeded
  def call(event)
    Rails.logger.log("Somebody paid us! Woohoo!")
  end
end
```

StripeEvent will automatically verify that the event it receives was actually from Stripe, so all you have to do is celebrate.

Two more little things will finish off our StripeEvent setup. We need to mount it in our application, like so (in `config/routes.rb`):

```ruby
mount StripeEvent::Engine => '/stripe-events'
```

Lastly, in your [Stripe settings](https://manage.stripe.com/account), on the webhooks tab, create a new entry and point it at your application. Done!

--Pete
