---
title: The Life of a Stripe Charge
id: charge
tags: Programming, Stripe
show_upsell: 'true'
---

One of the most common issues that shows up in the `#stripe` IRC channel is people setting up their front-end [Stripe Checkout](https://stripe.com/docs/checkout) integration and then expecting a charge to show up, which isn't really how Stripe works. In this post I'm going to walk through a one-off Stripe charge and hopefully illustrate how the whole process comes together.

--fold--

## Tokenization

The first stage in processing credit cards with Stripe is "tokenization", where Stripe turns a credit card number, expiration date, and CVC (***card verification code***, the three or four digit number printed on your card) into a single use token that your application can use in the second stage. 

To illustrate the process, here's a real (test-mode) Stripe checkout button. Go ahead and click it. You can fill it in with the card number `4242 4242 4242 4242`, any future expiration date, and any three digit CVC.

<script
  src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="pk_test_6pRNASCoBOKtIshFeQd4XMUh"
  data-amount="2000"
  data-name="Demo Site"
  data-description="2 widgets ($20.00)">
</script>

And here's the source:

```html
<script
  src="https://checkout.stripe.com/checkout.js" class="stripe-button"
  data-key="pk_test_6pRNASCoBOKtIshFeQd4XMUh"
  data-amount="2000"
  data-name="Demo Site"
  data-description="2 widgets ($20.00)">
</script>
```

If you have your web console open when you click "pay now" you'll see a request to a URL like this:

```text
https://api.stripe.com/v1/tokens?email=foo%40example.com
  &payment_user_agent=Stripe+Checkout
  &amount=0
  &iovation_blackbox=<a_very_large_string>
  &card[number]=4242+4242+4242+4242
  &card[cvc]=123
  &card[exp_month]=4
  &card[exp_year]=2014
  &card[name]=foo%40example.com
  &key=pk_test_6pRNASCoBOKtIshFeQd4XMUh
  &callback=sjsonp1390180955159
  &_method=POST
```

There's a few interesting things going on here. Stripe `POST`s at a `/tokens` API endpoint over https, which means everything is encrypted including the query params. These params include the card number, expiration date, and CVC, as well as the email address you put into the form and whether you want Stripe to remember you across sites. The API responds with a JSONP fragment that contains a single-use token that represents this card information.

Under the hood, Stripe is effectively storing the card in its ***vault*** of card information for a small amount of time and handing you back a way to refer to it so your server never knows the real information. This roundabout process is due to a set of banking industry regulations named ***PCI*** and is the key to Stripe's easy integration. Because your server-side process never knows the real card information, it doesn't fall into ***PCI compliance scope***. Being in scope involves a hefty set of security regulations and self-audits and is something that you really want to avoid.

## Stripe::Charge

The second stage of processing a card with Stripe is actually creating a charge. Until you create a charge from your server using your Stripe secret key everything is temporary. Passing an `amount` parameter to `checkout.js` as above will put a temporary authorization on the provided card but you still have to create the charge. Here's a Ruby/Sinatra example:

```ruby
post '/charge' do
  token = params[:stripeToken]
  Stripe.api_key = 'sk_test_abcdef1234567890'
  begin
    Stripe::Charge.create(
      card: token,
      amount: 2000,
      currency: 'usd',
      description: 'test charge'
    )

    redirect '/done'
  rescue Stripe::StripeError => e
    @error = e
    erb :error
  end
end
```

Between the call to `Stripe::Charge` and the `redirect` a whole series of actions happen between your server, Stripe's API, the card network, and at least one bank.

1. **Stripe API servers**
    The first thing that happens is your application makes an API call to Stripe's servers. This API call contains your Stripe secret key, the amount you want to charge, and the card you want to charge in the form of the token you got from `stripe.js` or `checkout.js`. 

2. **Card network**
    The next thing that happens is that Stripe's servers contact the ***card network***. Visa, Mastercard, Discover, and American Express are all examples of card networks. The card network's job is to route transactions to the bank that issued the card. For example, I have a Chase Visa card. Chase is the bank that issued the card and Visa is the card network that processes the transactions. Individual credit card processers don't have to know about all of the banks in the world, they just have to know how to contact the right network. In more traditional forms of credit card processing this step is performed by what's called a ***payment gateway*** but Stripe just handles it for you.
    
3. **Bank**
    The card network contacts the bank responsible for the card in question and asks to do two things, called an ***authorize*** and a ***capture***. An ***authorize*** request tells the bank to verify and reserve a certain amount of money out of the card's available credit for a transaction. A ***capture*** request tells the bank to actually transfer funds out of their account and into your Stripe account.

    Typically authorize and capture requests happen as one step, but sometimes merchants find it useful to be able to authorize for a larger amount than they end up charging, or to verify that you have funds available before they're ready to actually send you something. For example, a gas station will authorize something like $100 on your card temporarily until they know how much gas you pumped. Another example would be ordering a book from Amazon, who will authorize your card for the book but only charge when they ship it out of a warehouse. You can tell Stripe to create an authorization by passing the `capture=false` param to `Stripe::Charge`, and later capture it by calling the `Stripe::Charge#capture` method.

    One more note about banks. In the Chase example above, Chase is the bank and Visa is the network, but sometimes the card network is also the bank. The most common examples are American Express and Discover, but there are others.

4. **Back to Stripe**
    After the bank has either accepted or declined the charge it will respond to the card network, who will respond to Stripe, who will finally respond to your application's server-side `Stripe::Charge#create` method call and your application can carry on with whatever else it needs to do. In the example above, it redirects the customer's browser to the `/done` URL. If the customer's bank declined the charge or some other error happened Stripe's API will throw an exception which we can catch and render for the user.

## Customers and Subscriptions

Stripe-level customers work basically the same way as one-off charges. Tokenization works exactly the same but on the server, instead of creating a `Charge` object immedately you create a `Customer` object with the `stripeToken` parameter:

```ruby
post '/signup' do
  token = params[:stripeToken]
  Stripe.api_key = 'sk_test_abcdef1234567890'
  begin
    Stripe::Customer.create(
      card: token,
      email: params[:stripeEmail]
    )

    redirect '/done'
  rescue Stripe::StripeError => e
    @error = e
    erb :error
  end
end
```

When you create a customer you can pass in a `plan` parameter that refers to a previously-created `Stripe::Plan`. This will immediately start their subscription and transparently charge them for their first period.

You can also create charges using customers instead of cards:

```ruby
Stripe::Charge.create(
  customer: @customer.id,
  amount: 1000,
  currency: 'usd'
)
```

## Wrap Up

Stripe makes credit card processing simple by wrapping up a bunch of formerly independent pieces, letting you concentrate on your application. That said, knowing the basics of those pieces will help you understand what's going on under the hood and more importantly help you ask the right questions when things don't go quite right.
