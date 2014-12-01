---
title: What is the best modern payment provider?
id: pay
topic: Business
tags: Stripe, Business
description: 'A comparision of modern payment providers including Stripe, Braintree, Balanced, and more.'
show_upsell: true
show_upsell_header: false
---

**Your business has to get paid**, but how that happens is a complicated question, and the modern payment landscape is vast. How do you pick?

**What payment service is the best fit for your business?**

This list highlights the biggest modern payment providers in the market, where "modern" includes features like integrated merchant account and gateway services, RESTful APIs, and well maintained SDKs. 

You can use this list to help you narrow down the choices for your business.

--fold--

## [Stripe](https://stripe.com)

* Credit card payments
* Alipay in China and Bitcoin (in beta)
* 2.9% + $0.30, volume breaks after $80k/mo
* $0.25 for API-driven payouts (automatic payouts are free)

### Pros

* Good overall fee structure
* Great API and documentation
* Built-in subscription services
* Excellent 3rd party ecosystem
* Offers Alipay and Bitcoin
* Many countries
* Flexible statement descriptors

### Cons

* Does not offer the money flow flexibility that some businesses require
* Not available worldwide (yet)
* No phone support (still)

---

## [Balanced](https://www.balancedpayments.com)

* Credit cards and US bank accounts
* 2.9% + $0.30 credit cards, 1% + $0.30 bank account ($5 fee cap)
* $0.25 to non-merchant-owned bank accounts

### Pros

* Extremely flexible (escrow account, multiple ways to get money in and out)
* Decent service
* Very nice API
* Flexible statement descriptors

### Cons

* Poor documentation
* No built-in subscription services
* No 3rd party ecosystem
* US only

---

## [Braintree](https://www.braintreepayments.com)

* Credit cards
* 2.9% + $0.30 after first $50k account lifetime gross volume

### Pros

* Excellent support
* Easy PayPal integration
* Easy drop-in form (v.zero)
* Flexible statement descriptors
* Braintree Ignition (no fees on first $50k)

### Cons

* Owned by PayPal
* Dashboard interface not very powerful
* No 3rd party ecosystem
* US, Canada, Australia, Europe

---

## [WePay](https://www.wepay.com)

* Credit cards and bank transfers
* 2.9% + $0.30 cards, 1% + $0.30 bank transfers

### Pros

* Handles chargebacks transparently and without any fees
* Easy iframe integration
* Simple built-in subscriptions

### Cons

* US and Canada only
* Fixed statement descriptor "WEPAY, INC"

---

## [PayPal](https://www.paypal.com)

* Credit card and bank transfers
* 2.9% + $0.30 with price breaks at [various volumes](https://www.paypal.com/webapps/mpp/merchant-fees)

### Pros

* Very much international
* Easy to get started
* Comfortable for customers

### Cons

* Most APIs are old and bad
* Documentation is confusing
* IPNs are brittle and easy to mess up
* Can be expensive

---

## [Dwolla](https://www.dwolla.com/)

* Bank transfers
* $0.25 per transfer, in or out

### Pros

* Inexpensive
* Easy to use

### Cons

* No credit card processing
* Users have to have accounts
* Slow, since it's just ACH
* API is limited
* US only

---

## [BitPay](https://bitpay.com)

* Bitcoin
* Transactions are free
* Free with limited email support, $300/mo for phone support

### Pros

* Easy to use API
* No transaction fees
* Offers payment diversity for your customers
* Prices in hard currency, customer pays with BTC
* Can settle to your bank account in a variety of currencies

### Cons

* Customers have to have Bitcoin already
* Bitcoin is still a new, speculative, fast-moving universe

---

**P.S.** Looking for help navigating this list and choosing the provider, or maybe mix of providers, that best fit your business? [Contact me](mailto:hi@petekeen.net) and let's chat.

---
