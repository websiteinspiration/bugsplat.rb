---
title: ! 'Program Your Finances: Algorithmic Savings'
id: algo
tags: Personal Finance, Ledger
topic: Finance
description: Using algorithms to calculate savings targets instead of percentage-based automated ledger transactions.
---

When I started my first full time job in 2007 I started putting away a little bit of my paycheck every two weeks into savings. For the past two years I haven't been doing that manually. Instead, I've been using Ledger's fantastic [automated transactions](/program-your-finances-automated-transactions) to put money away without having to think about it, both for long term goals and [envelope budgeting](/program-your-finances-envelope-budgeting).

Automated saving transactions have been great, except that they never really captured the whole picture, nor did they fit a few constraints I wanted:

* When a fund is below a minimum threshold it should get priority
* When a fund is above a maximum it should not receive any more savings
* I don't want to save any more than I actually have available in a given month

For example, I keep an emergency fund that I keep at about $15k. If it falls below, say, $13k, I want to boost it up as fast as possible. But, if I only have $10 left at the end of the month I don't want to try to save more than that.

## Algorithms

Ledger's automated transactions can't reach that kind of flexibility because they don't have access to arbitrary account balances (at least as far as I can tell). Also, because they're evaluated at parse time, the first 300 lines of my ledger file are automated transaction rules.

Instead of using automated transactions, I wrote a little program that generates a transaction to be pasted into my ledger. It takes the three constraints above and turns the cash left over at the end of the month into savings without me having to put numbers into a spreadsheet and manually construct the Ledger transaction.

The algorithm happens in two stages and acts on a set of rules, something like this:


```ruby
RULES = [
  { 'Emergency'      => { min: 13000, max: 15000, weight: 10 } },
  { 'Medical'        => { min:  1500, max:  4000, weight:  8 } },
  { 'House'          => { min:  3000, max: 15000, weight:  8 } },
  { 'Furniture'      => { min:   200, max:  4000, weight:  4 } },
  { 'Travel'         => { min:  2000, max: 20000, weight:  4 } },
]
```

It also depends on having a few numbers available, namely the balance of each fund in the set of rules as well as how much excess cash there was at the end of the month.

The algorithm then takes two passes over the rules.

1. Sum up the weights in all of the rules. If the account balance is greater than or equal to the max, set the weight to zero. If it's below the min, multiply the weight by 4. Keep track of the total weight in the set and the calculated weight for each rule.

2. For each rule, calculate the percentage "share" by dividing the account weight by the total weight. Then calculate the amount of this share by multiplying it by the remaining income, up to the max for that fund. Subtract that amount from the remaining income, subtract that rule's weight from the total weight, and continue down the rules until you're out of money.

Each rule is evaluated in terms of two shrinking pies: the total weight and the remaining income. When no funds hit their max value this is strictly equivalent to a straight percentage savings, but elegantly deals with both the min and max situations.

Here's what that looks like in code:

```ruby
account_weights = {}
total_weight = 0

RULES.each do |rule|
  account = rule.keys.first
  rules = rule.values.first
  weight = rules[:weight]

  if (fund_balances[account] || 0) < rules[:min]
    weight = weight * 4
  elsif fund_balances[account] >= rules[:max]
    weight = 0
  end

  total_weight += weight
  account_weights[account] = weight
end

xtns = {}
RULES.each do |rule|
  account = rule.keys.first
  rules = rule.values.first
  weight = account_weights[account]
  balance = fund_balances[account] || 0
  share = weight.to_f / total_weight.to_f

  deposit_amount = [
    remaining_income * share, 
    rules[:max] - balance
  ].min

  next if deposit_amount.round == 0

  total_weight -= weight
  remaining_income -= deposit_amount
  xtns[account] = deposit_amount
end
```

This algorithm has some great properties:

* The priority of a fund is determined by it's placement in the rules. Earlier funds get funded before later funds.
* The amount a fund gets is determined by it's weight. Higher weight gets a bigger share.
* Funds below their minimum get plumped up with the weight multiplier, while full funds automatically drop out.

The only drawback is that I have to manually run this script every month, but I feel like that's a small price to pay for the flexibility this gives me. If you're interested in the gory details of the script I put the whole thing in [a gist](https://gist.github.com/peterkeen/ff1c0afb9f7c9a7d10fb). I'd love to hear your thoughts, even if you just want to tell me I'm crazy.
