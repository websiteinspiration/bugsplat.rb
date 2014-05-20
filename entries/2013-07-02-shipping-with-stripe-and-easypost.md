---
title: Shipping with Stripe and EasyPost
id: 0e350
tags: Programming, Stripe
show_upsell: 'true'
topic: Stripe
description: Make a thing, sell it with Stripe, ship it with EasyPost. Cruise control for cool.
---

[stripe]: https://stripe.com
[easypost]: https://www.easypost.com
[yt-quadcopter]: http://www.youtube.com/results?search_query=quadcopter&oq=quadcopter&gs_l=youtube.3..0l10.52.1051.0.1171.10.5.0.5.5.0.114.411.2j3.5.0...0.0...1ac.1.11.youtube.kAqJ9C9hPz8


Let's say that instead of running a Software as a Service, you're actually building and shipping physical products. Let's say quadcopter kits. People come to your website, buy a quadcopter kit, and then you build it and ship it to them. It takes you a few days to build the kit, though, and you would rather not charge the customer until you ship. Traditionally [Stripe][stripe] has been focused on paying for online services but recently they added the ability to *authorize* and *capture* payments in two steps. In this post we're going to explore billing with Stripe and shipping with [EasyPost][easypost] with separate charge and capture.

--fold--

* [Stripe API Docs](https://stripe.com/api/ruby)
* [EasyPost API Docs](https://www.easypost.com/docs/ruby)

### Step 1: Calculate Shipping

EasyPost makes it really simple to calculate shipping rates. Just take the customer's shipping address and create an `EasyPost::Shipment` object:

```ruby
from_address = EasyPost::Address.create(
  name:    'Pete Keen',
  street1: '618 NW Glisan Ave',
  city:    'Portland',
  state:   'OR',
  zip:     '97211',
  country: 'US',
  email:   'pete@petekeen.net'
)

to_address = EasyPost::Address.create(
  name:    params[:to_name],
  street1: params[:to_street1],
  city:    params[:to_city],
  state:   params[:to_state],
  zip:     params[:to_zip],
  country: params[:to_country],
  email:   params[:email],
)

parcel = EasyPost::Parcel.create(
  length: 10,
  width: 10,
  height: 6,
  weight: 30,
)

shipment = EasyPost::Shipment.create(
  to_address: to_address,
  from_address: from_address,
  parcel: parcel
)

@rates = shipment['rates']
```

Display those rates to the customer, have them pick the one they want, and then move on to the next step.

### Step 2: Authorize

Charging a card and just doing the authorization step are remarkably similar. Just get the user's credit card info with `stripe.js` or `checkout.js` and then make the charge with the `capture` parameter set to `false`:

```ruby
charge = Stripe::Charge.create(
  card:   params[:stripeToken],
  amount: 10000 + (@selected_rate['rate'].to_f * 100).to_i,
  currency: 'usd',
  capture: false
)
```

This will authorize a charge of $100 plus the shipping rate for up to seven days. EasyPost gives back shipping rates as decimal strings, so to give it to Stripe we have to convert it to a number, then to cents, and finally to an integer. Save `shipment.id` and `charge.id` to your database, you'll need them later.

### Step 3: Build the Product

You're on your own here. Just make sure to get everything done in 7 days, because after that Stripe will release the funds from the customer's credit card and the charge object won't be valid anymore.

### Step 4: Ship It!

Now you're at the point where you're ready to ship. All you have to do now is purchase the shipping label and tell Stripe to capture the charge:

```ruby
shipment = Shipment.retrieve(saved_shipment_id)
label = shipment.buy

charge = Stripe::Charge.retrieve(saved_charge_id)
charge.capture

label_url = label['label_pdf_url']
# display the url and print it
```

Now just print off the PDF, tape it to your box, and take the package to the UPS or FedEx store or the post office and drop it off. Wait a few weeks and [search YouTube for quadcopter videos][yt-quadcopter] and you'll be sure to see one of your kits, gracefully flying around.

## Conclusion

Stripe is awesome for processing credit cards. EasyPost is the easiest way to buy shipping known to man. Combine them and you have yourself a simple way to sell and ship physical products in the US and worldwide.
