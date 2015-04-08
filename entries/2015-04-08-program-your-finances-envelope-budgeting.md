---
title: ! 'Program Your Finances: Envelope Budgeting'
id: env
description: "Use Ledger's automated transactions to implement envelope-style budgeting."
tags: Personal Finance, Ledger
topic: Finance
---

*Note: you can find much more information about ledger on [ledger-cli.org](http://ledger-cli.org), including links to official documentation and other implementations. Also, check out my [intro to accounting with Ledger](/keeping-finances-with-ledger).*

A few years ago I heard about YNAB, or [You Need A Budget](https://www.youneedabudget.com). YNAB is a [set of rules](https://www.youneedabudget.com/method) and associated software that help people to dig themselves out of financial holes and prosper with a budget. The rules are:

1. Give Every Dollar a Job
2. Save for a Rainy Day
3. Roll With the Punches
4. Live on Last Month's Income

YNAB embraces both traditional budgeting, where you have a fixed amount of money every month for a category, as well as "envelope budgeting", where you put a fixed amount every month into a category, but if you don't spend all of that it rolls to the next month.

In this blog post I'm going to talk about how to smoothly implement envelope budgeting in Ledger land.

## Envelope Budgeting: A Primer

Envelope budgeting is a pretty simple concept. When you receive a paycheck, you separate out a certain amount of money for each category and put it in an envelope. When the money in the envelope is gone, you can't spend any more for that category. Some financial systems actually have you draw out your entire paycheck in cash and put it into physical envelopes, but we're not going to go that far.

## Chart of Accounts

If you've ever taken an accounting class you're probably familiar with the concept of a "chart of accounts". In an accounting system, your accounts make a tree, starting from five root accounts:

* Assets
* Liabilities
* Income
* Expenses
* Equity

For example, if you have a checking account, that's an asset, like this: `Assets:Checking`. A credit card would be a liability: `Liabilities:Credit Card`. Your paycheck would be income: `Income:Salary`, and getting groceries would be an expense: `Expenses:Food:Groceries`. Equity is out of scope for this discussion, but in a personal finance system it's typically used when you're declaring opening balances in accounts.

## Parallel Accounts

The best way to implement envelope budgeting in Ledger is using a parallel chart of accounts. That is to say, a set of accounts that's outside of your normal real-money assets, income, expenses, or liabilities. I've chosen to use `Assets:Funds` and `Liabilities:Funds` ("fund" as in "slush fund") in the examples that follow, but you can use whatever you want as long as it doesn't mix with your real money accounts.

Let's say our water bill comes every other month and averages $100. In a traditional monthly budgeting system this would be hard to account for, since some months will be zero and some will have a charge. With our parallel accounts, though, this is easy:

```text
2015/04/02 * Salary
    Assets:Checking              $1,000.00
    Income:Salary

2015/04/02 * Water Bill Accrual
    Assets:Funds:Water              $50.00
    Liabilities:Funds:Water

2015/05/02 * Salary
    Assets:Checking              $1,000.00
    Income:Salary
    
2015/05/02 * Water Bill Accrual
    Assets:Funds:Water              $50.00
    Liabilities:Funds:Water
```

At the beginning of April and May, we receive our salary deposit and set aside $50 each time for your water bill. Notice how, in the accrual account, we're depositing into our `Assets:Funds:Water` account and balancing it out from a companion liability. This reflects the fact that in double entry accounting every transaction has to balance, and dedicated balancing liabilities make things easier later on. Here are our balances:

```text
           $2,100.00  Assets
           $2,000.00    Checking
             $100.00    Funds:Water
          $-2,000.00  Income:Salary
            $-100.00  Liabilities:Funds:Water
--------------------
                   0
```

Now let's look at what happens when our water bill comes due:

```text
2015/05/03 * Water Bill
    Expenses:Water                  $95.00
    Assets:Checking                $-95.00
    Liabilities:Funds:Water         $95.00
    Assets:Funds:Water             $-95.00
```

Notice how we pull $95 out of our checking account and *also* pull $95 out of our `Liabilities:Funds:Water` account.

Here's what the balances look like now:

```text
           $1,910.00  Assets
           $1,905.00    Checking
               $5.00    Funds:Water
              $95.00  Expenses:Water
          $-2,000.00  Income:Salary
              $-5.00  Liabilities:Funds:Water
--------------------
                   0
```

$95 went from the checking account into the water expense and the water fund still has $5 in it.

## Automated Envelopes

This system would be a pain in the butt if we had to manually track it for every transaction. Thankfully, Ledger has us covered with automated transactions.

An automated transaction looks a lot like a normal transaction, except it starts with an `=` and has an expression instead of a payee and date. Let's see what our water accrual rule looks like:

```text
= /Income:Salary/
    * Assets:Funds:Water         $50.00
    * Liabilities:Funds:Water   $-50.00
```

In this example the expression is a regular expression surrounded by `/`s. `/Income:Salary/` will match any posting with that as the account name.

After the expression we have two lines. They start with a `*` to indicate that they're cleared transactions. Next is the account name and an amount, just like in a normal ledger transaction.

Now, let's set up a matching rule for spending out of the envelope:

```text
= /Expenses:Water/
    * Liabilities:Funds:Water      1.0
    * Assets:Funds:Water          -1.0
```

This one is very similar to the first, except for those amounts. Notice how they don't have a commodity attached to them? In automated transactions, ledger will treat an amount without a commodity as a percentage, where 1.0 = 100%. This rule means that we want to match every water expense and pull 100% of it out of our water envelope.

Putting it all together, here's what the automatic version looks like:

```text
= /Income:Salary/
    * Assets:Funds:Water            $50.00
    * Liabilities:Funds:Water      $-50.00

= /Expenses:Water/
    * Liabilities:Funds:Water          1.0
    * Assets:Funds:Water              -1.0

2015/04/02 * Salary
    Assets:Checking              $1,000.00
    Income:Salary

2015/05/02 * Salary
    Assets:Checking              $1,000.00
    Income:Salary

2015/05/03 * Water Bill
    Expenses:Water                  $95.00
    Assets:Checking                $-95.00
```

Here's the resulting register report:

```text
15-Apr-02 Salary     Assets:Checking          $1,000.00 $1,000.00
                     Income:Salary           $-1,000.00         0
                     Assets:Funds:Water          $50.00    $50.00
                     Liabilities:Funds:Water    $-50.00         0
15-May-02 Salary     Assets:Checking          $1,000.00 $1,000.00
                     Income:Salary           $-1,000.00         0
                     Assets:Funds:Water          $50.00    $50.00
                     Liabilities:Funds:Water    $-50.00         0
15-May-03 Water Bill Expenses:Water              $95.00    $95.00
                     Assets:Checking            $-95.00         0
                     Liabilities:Funds:Water     $95.00    $95.00
                     Assets:Funds:Water         $-95.00         0
```

For every paycheck, $50 went into our fund. When we paid the water bill, $95 came out of the fund. To set this up for more envelopes, just create a corresponding pair of rules for each one.

One last thing. What if we want to change how much we're setting aside in the water envelope? Let's say our rates go up and we now need to save $55 from each paycheck instead of $50. Here's how we do that:


```text
= /Income:Salary/ and expr date >= [2015/04/01] && date < [2015/06/01]
    * Assets:Funds:Water         $50.00
    * Liabilities:Funds:Water   $-50.00

= /Income:Salary/ and expr date >= [2015/06/01]
    * Assets:Funds:Water         $55.00
    * Liabilities:Funds:Water   $-55.00
```

We can't just delete the old rule because then the transactions from before would be off. Instead, we add date expressions to our rules. Ledger's expression grammar is pretty complicated and not very well documented, but this should be sufficient for the rules you'll be writing for automatic envelopes. [Ledger's manual has more documentation on automatic transactions](http://ledger-cli.org/3.0/doc/ledger3.html#Automated-Transactions).

I put the examples in [this gist](https://gist.github.com/peterkeen/d508e26ebd353f22b766) if you'd like to play with them. You'll need Ledger 3 installed.
