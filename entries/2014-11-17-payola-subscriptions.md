---
title: 'Payola v1.2: Now with Subscriptions'
id: p12
tags: Stripe, Programming
topic: Stripe
description: 'Payola is a drop-in Rails engine for accepting payments with Stripe, now with Subscription support'
canonical_url: 'https://www.payola.io/blog/payola-subscriptions'
---

Today is release day for [Payola v1.2.0](https://www.payola.io) and the big watch word is **subscriptions**. So now that they're here, how do you use subscriptions with Payola? It's easy:

1. Install the gem
2. Configure a model
3. Set up a form
4. Profit!

--fold--

Let's go through these in a bit more detail.

## 1. Installation

Add `payola-payments` to your `Gemfile`:

```ruby
gem 'payola-payments', '>= 1.2.0'
```

Now run bundler and install the migrations:

```bash
$ bundle install
$ rails g payola:install
$ rake db:migrate
```

Payola assumes you have your Stripe keys in environment variables named `STRIPE_SECRET_KEY` and `STRIPE_PUBLISHABLE_KEY`. Make sure to set those up or configure them in Payola's initializer.

## 2. Model

Payola tracks everything about a subscription for you, but you have to tell it about your plans. For that, create a `Plan` model and include the appropriate Payola module:

```bash
$ rails g model Plan \
    stripe_id:string \
    name:string \
    amount:integer \
    interval:string \
    interval_count:integer
$ rake db:migrate
```

Now open up `app/models/plan.rb` and add the concern:

```ruby
class Plan < ActiveRecord::Base
  include Payola::Plan
end
```

At this point you should be able to open up a console and add a plan:

```bash
$ rails console
irb(main):001:0> Plan.create(name: 'Test Plan', stripe_id: 'test-plan', amount: 100, interval: 'month', interval_count: 1)
```

This will create a `Plan` object as well as create a plan within Stripe.

## 3. Form

Payola currently only supports custom forms for subscriptions but it makes it as easy as possible to do. Let's create a simple controller first at `app/controllers/subscriptions_controller.rb`:

```ruby
class SubscriptionsController < ApplicationController
  def new
    @plan = Plan.first
  end
end
```

This is what our form is going to look like:

<img src="https://d2s7foagexgnc2.cloudfront.net/files/184ec12c3fd67e6f7775/payola_subscription_form.png"></img>

Here's what the view looks like, using Bootstrap 3 for layout:

```rhtml
<div class="row">
  <div class="col-xs-8 col-xs-offset-2">
    <div class="well">
    <%= form_tag('/subscribe',
      role: 'form',
      class: 'payola-subscription-form',
      'data-payola-base-path' => '/payola',
      'data-payola-error-selector' => '.payola-error',
      'data-payola-plan-type' => @plan.plan_class,
      'data-payola-plan-id' => @plan.id) do %>
      <div class="form-group">
        <label>Email Address</label>
        <input type="email"
               name="email"
               data-payola="email"
               placeholder="you@example.com"
               class="form-control"></input>
      </div>
      <div class="form-group">
        <label>Card number</label>
        <input type="text"
               size="20"
               data-stripe="number"
               class="card-number form-control"
               placeholder="**** **** **** ****"></input>
      </div>
      <div class="row">
        <div class="col-md-6">
          <div class="form-group">
            <label>Exp</label>
            <input type="text"
                   size="8"
                   class="exp-date form-control"
                   placeholder="MM / YY"></input>
            <input type="hidden" data-stripe="exp_month"></input>
            <input type="hidden" data-stripe="exp_year"></input>
          </div>
        </div>
        <div class="col-md-6">
          <div class="form-group">
            <label>CVC</label>
            <input type="text"
                   size="4"
                   data-stripe="cvc"
                   class="form-control"
                   placeholder="***"></input>
          </div>
        </div>
      </div>
      <div class="text-center">
        <input type="submit" value="Subscribe" class="btn btn-info btn-lg"></input>
      </div>
      <div class="alert alert-warning payola-error" style="display: none"></div>
      <% end %>
    </div>
  </div>
</div>
```

Payola's subscription form behavior is triggered by your form having the class `payola-subscription-form`. After that, you just mark up the data destined for Stripe with `data-stripe` attributes. Any field with a `name` attribute will get submitted along with the form once Payola is done doing it's thing.

This particular form has a few additional niceties provided by the [jquery.payment](https://github.com/stripe/jquery.payment) library from Stripe. Here's the javascript for the form, in `app/assets/javascripts/form.js`:

```javascript
$(function() {
  $('.exp-date').payment('formatCardExpiry');
  $('input[data-stripe="number"]').payment('formatCardNumber');
  $('input[data-stripe="cvc"]').payment('formatCardCVC');

  $('.exp-date').on('keyup', function() {
      var e = $('.exp-date').first();
      var out = $.payment.cardExpiryVal(e.val());
      $('input[data-stripe="exp_month"]').val(out.month);
      $('input[data-stripe="exp_year"]').val(out.year);
  });

  $('.card-number').on('keyup', function() {
    var e = $('.card-number').first();
    var type = $.payment.cardType(e.val());
    var img = "card.png";
    switch(type) {
        case "visa":
          img = "visa.png";
          break;
        case "mastercard":
          img = "mastercard.png";
          break;
        case "discover":
          img = "discover.png";
          break;
        case "amex":
          img = "amex.png";
          break;
    }
    e.css('background-image', 'url(/images/' + img + ')');
  });
  
});
```

This does three separate things. First, it sets up formatters on the form's expiration date, card, and cvc number fields. Next, the JS sets up another event handler that uses `jquery.payment`'s `cardExpiryVal` function to parse the card expiration date into a month and a year, and sets the hidden fields to that value.

Finally, it sets up an event handler that changes the credit card icon based on what type of card the customer is entering. The particular images that I'm using are from [a very nice set of flat icons](https://creativemarket.com/Shpigford/12572-Flat-Credit-Card-Icons) off of Creative Market. Shopify put out a [free set](http://www.shopify.com/blog/6335014-32-free-credit-card-icons) a while back as well.

In order to make the icon actually show up in the right place, you need to add this small CSS snippet:

```css
.card-number {
  background-image: url(/images/card.png);
  background-repeat: no-repeat;
  background-size: 30px;
  background-position: right 10px center;
}
```

(`card.png` is the default green card image.)

Ok, so now we have a form, but what exactly happens here? Payola Subscriptions works like this:

1. When the customer hits the submit button, Payola intercepts that and sends the fields tagged with `data-stripe` to Stripe to get a card token.
2. When Stripe returns a token, Payola POSTs that along with the email address field to `/payola/subscribe/:plan_class/:plan_id`, which creates a `Payola::Subscription` and attempts to create a `Stripe::Customer`. All of this happens in the background, so the user's browser polls your application every 500 milliseconds until the background job is done.
3. When Payola is finished, the user's browser will submit the original form to your application, with an additional `payola_subscription_guid` param tacked on. Your controller should associate that `Payola::Subscription` object with your customer's record.

How your application handles step 3 is up to you. Some applications may want to attach the subscription to an organization account while others may want to attach it to a user directly. In any case, `Payola::Subscription` has a polymorphic `owner` attribute that you should use. For example:

```ruby
sub = Payola::Subscription.find_by(guid: params[:payola_subscription_guid])
sub.owner = current_user
sub.save!
```

## 4. Profit!

At this point you have a functional subscription system. Payola provides all sorts of hooks and notifications that you can use to trigger additional application-specific behavior, which you can read all about in [the README](https://github.com/peterkeen/payola).

---

**P.S.:** Payola Pro is an add-on to Payola that provides priority email support, pre-built integrations with several 3rd party services, Stripe Connect marketplace support, along with a lawyer-friendly commercial license. You can read all about it at [payola.io/pro](https://www.payola.io/pro), and all of the modules have documentation on [the Payola wiki](https://github.com/peterkeen/payola/wiki).

**P.P.S.:** I want to thank [Jeremy Green](http://www.octolabs.com) who has been instrumental in driving this forward. Subscriptions would probably be another month away without Jeremy's help.
