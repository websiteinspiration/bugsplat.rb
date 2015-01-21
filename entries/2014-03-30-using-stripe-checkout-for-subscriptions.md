---
title: Using Stripe Checkout for Subscriptions
id:    chksb
tags:  Programming, Stripe
show_upsell: true
description: Stripe provides a gorgeous pre-built credit card form called Stripe Checkout. Learn how to best use it for subscription applications.
topic: Stripe
---

Stripe provides a gorgeous pre-built credit card form called [Stripe Checkout](https://stripe.com/docs/checkout). Checkout is mainly intended for one-off purchses like [Dribbble](http://dribbble.com/) or [my book](/mastering-modern-payments). Many people want to use it for their Stripe-powered subscription sites so in this article I'm going to present a good way of doing that.

--fold--

Here's a really basic Checkout button (in fact, the same button as on Stripe's documentation site):

<script
  src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="pk_test_1MCYLYHQDa4DwnBoKd5CqoaP"
  data-image="https://stripe.com/img/documentation/checkout/marketplace.png"
  data-name="Demo Site"
  data-description="2 widgets ($20.00)"
  data-amount="2000">
</script>

```html
<script
  src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="pk_test_1MCYLYHQDa4DwnBoKd5CqoaP"
  data-image="https://stripe.com/img/documentation/checkout/marketplace.png"
  data-name="Demo Site"
  data-description="2 widgets ($20.00)"
  data-amount="2000">
</script>
```

There are several things in here that don't really work well for a subscription site, but they're easy to fix. For example, we don't want to show an amount in that way and the description doesn't make much sense. Here's a another version with a few changes:

<script
  src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="pk_test_1MCYLYHQDa4DwnBoKd5CqoaP"
  data-image="https://stripe.com/img/documentation/checkout/marketplace.png"
  data-name="Demo SaaS Site"
  data-description="Pro Subscription ($29 per month)"
  data-panel-label="Subscribe"
  data-label="Subscribe">
</script>

```html
<script
  src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="pk_test_1MCYLYHQDa4DwnBoKd5CqoaP"
  data-image="https://stripe.com/img/documentation/checkout/marketplace.png"
  data-name="Demo SaaS Site"
  data-description="Pro Subscription ($29 per month)"
  data-panel-label="Subscribe"
  data-label="Subscribe"
  data-amount="2900">
</script>
```

Stripe lets you customize most of the text on the form. In this example, we changed tha panel button to say "Subscribe" instead of "Pay", and changed the description to something more appropriate for our site. You can also see that we added a template variable to the `data-description` attribute, so if we had multiple tiers all we'd have to change is the word "Pro" and the `data-amount` attribute.

There's one last thing that we can change on here. There's that "Remember Me" checkbox, which can be confusing for customers. They're signing up for a subscription site, so aren't you already remembering them? Thankfully, Stripe recently added the ability to disable that checkbox:

<script
  src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="pk_test_1MCYLYHQDa4DwnBoKd5CqoaP"
  data-image="https://stripe.com/img/documentation/checkout/marketplace.png"
  data-name="Demo SaaS Site"
  data-description="Pro Subscription ($29 per month)"
  data-panel-label="Subscribe"
  data-label="Subscribe"
  data-allow-remember-me="false">
</script>

```html
<script
  src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="pk_test_1MCYLYHQDa4DwnBoKd5CqoaP"
  data-image="https://stripe.com/img/documentation/checkout/marketplace.png"
  data-name="Demo SaaS Site"
  data-description="Pro Subscription ($29 per month)"
  data-panel-label="Subscribe"
  data-label="Subscribe"
  data-amount="2900"
  data-allow-remember-me="false">
</script>
```

Great! Nice, streamlined, beautiful form without having to design it yourself. But what if you don't like that blue button? Stripe provides a Javascript API so you can make any link or button pop up Checkout:

<button class="btn btn-primary btn-large" id="stripe-demo">Subscribe</button>

<script src="https://checkout.stripe.com/checkout.js"></script>
<script>
var handler = StripeCheckout.configure({
  key: "pk_test_1MCYLYHQDa4DwnBoKd5CqoaP",
  image: "https://stripe.com/img/documentation/checkout/marketplace.png",
  name: "Demo SaaS Site",
  description: "Pro Subscription ($29 per month)",
  panelLabel: "Subscribe",
  allowRememberMe: false
});

document.getElementById('stripe-demo').addEventListener('click', function(e) {
  handler.open();
  e.preventDefault();
});
</script>

```
<button class="btn btn-primary btn-large" id="stripe-demo">Subscribe</button>

<script src="https://checkout.stripe.com/checkout.js"></script>
<script>
var handler = StripeCheckout.configure({
  key: "pk_test_1MCYLYHQDa4DwnBoKd5CqoaP",
  image: "https://stripe.com/img/documentation/checkout/marketplace.png",
  name: "Demo SaaS Site",
  description: "Pro Subscription ($29 per month)",
  panelLabel: "Subscribe",
  allowRememberMe: false
});

document.getElementById('stripe-demo').addEventListener('click', function(e) {
  handler.open();
  e.preventDefault();
});
</script>
```

Pretty straight forward. Every attribute that you pass into the simple integration using `data` attributes instead gets passed into the `configure` method. You can pass overrides into the `open` method, so for example, if you had a series of buttons with a specific class and `data` attributes for the description, you could get that off of the event target and pass it into `open`.

### But what about passwords?

If you're building a subscription product you'll likely want the user to set their password. There's two ways you can use Stripe Checkout and still have the user set their password:

1. Have a second step after Stripe Checkout that allows the user to set up their account, including their password.

2. Send a confirmation email to the user immediately after the subscription flow that brings them to a password reset screen.

Of the two I prefer the second, since you should be confirming the user's email address anyway. That said, you should test with your customers and see what works best for them.

### Now what?

Of course, none of this is worth anything without creating the customers. For that, you'll need to use Stripe's server-side APIs along with your secret key. Stripe has [excellent documentation](https://stripe.com/docs/subscriptions) on how this works.

*Note: this describes Stripe Checkout as of March 30th, 2014. Stripe is continually updating and testing Checkout, so things may change in the future.*
