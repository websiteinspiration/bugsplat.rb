---
title: Stripe Account Balances for Service Credits
id:    sab
tags:  Stripe, Programming
show_upsell: true
topic: Stripe
description: Your customer earned a referral fee. You can pay them with a credit to their Stripe account balance.
canonical_url: 'https://www.masteringmodernpayments.com/blog/stripe-account-balances-for-service-credits'
---

Say you want to give a customer an account credit for some reason. They're an especially good customer, or your service was down for a few minutes and you want to give service credits, or some other reason. You can do this using Stripe's `account_balance` feature.

--fold--

Here's an example situation. You run a DNS service and had a five minute outage last month. Your SLA (service level agreement) says that you give a one day credit for a five minute outage, and for your customer Bob that's equal to $1.

Here's how you credit Bob's account:

```ruby
bob = Stripe::Customer.retrieve('cus_bobskey')
bob.account_balance = bob.account_balance - 100
bob.save
```

Bob's card will be charged $9 for his next invoice: $10 from his monthly plan and -$1 from his account balance. After this invoice, his account balance will be set back to 0. Note that you have to set the account balance to a *negative number*. If you set it to a positive number, that amount will be *added* to Bob's next invoice instead of subtracted. It's also a good practice to subtract the amount from their existing balance. Most of the time this will be 0, but if they happen to already have a balance you don't want to stomp on it.

Here's another example. You want to give Cindy two free months for upgrading to your biggest plan, from the $20 Hobby plan to the $100 Super Startup plan. The same idea applies as for Bob:

```ruby
cindy = Stripe::Customer.retrieve('cus_cindyskey')
cindy.plan = 'super_startup_100'
cindy.account_balance = cindy.account_balance - 20000
cindy.save
```

Cindy is halfway through the billing month when she decides to upgrade. On her next invoice, she'll see the following line items:

* $50 for the half month
* $100 for the next full month
* $-150 from her account balance

Her card won't actually be charged because the entire amount came out of her account balance, which is now $-50. On month 2, she'll receive that $50 from her account balance and be charged the remaining $50 for her plan, and then on month 3 she'll be charged the full $100.

----

You can use the account balance with positive numbers, of course. This would add an additional line item to the customer's invoice for the `account_balance` amount. It's usually better to create line items directly, though, because that way you have control over the description.

* [Stripe's `update_customer` documentation](https://stripe.com/docs/api#update_customer)
