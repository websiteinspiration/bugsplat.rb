Title: Program Your Finances: Automated Transactions
Date:  2011-12-18 18:32:27
Tags:  Personal Finance, Ledger
Id:    ea00f

*Note: you can find much more information about ledger on [ledger-cli.org](http://www.ledger-cli.org), including links to official documentation and other implementations*

I've been using [Ledger](http://www.ledger-cli.org) for almost five years now to keep track of my personal finances. For three of those years I've lived with a roommate of one form or another. Part of living with a roommate is splitting up bills. Some people decide to do this by dividing the bills up between roommates. For example, Pete pays the electric and gas bills and Andrew pays the water and the cable. Other roommates decide to nominate one person to have all of the bills in their name and post the amounts due every month for everyone to see. This is what my girlfriend and have been doing and it's been working great. All of the bills are in my name and I give her a summary every month and she hands me a check. Easy peasy.

Of course, being a complete and utter nerd means that I have to make this more complicated than it needs to be in the name of reducing the amount of work I have to do.

--fold--

### Automated Transactions

Ledger has an extremely handy feature named _automated transactions_. The basic idea is that you provide a template transaction and a pattern to match, and `ledger` will insert the filled-in template transaction every time the pattern matches. Here's an example:

```text
= /Expenses:Utils:/
    $account                        -0.5
    Assets:Receivable                0.5
```
        
This instructs ledger to insert a transaction for 50% of the total
transaction amount every time a transaction matches the given regexp (`/Expenses:Utils:/`). The template variable `$account` will be replaced with the matched account. So if we have this transaction:

```text
2011/12/18 Electric Company
    Expenses:Utils:Electric          $50
    Assets:Checking
```
        
ledger will automatically insert this immediately following:

```text
2011/12/18 Electric Company
    Expenses:Utils:Electric         $-25
    Assets:Receivable                $25
```

I use an automatic transaction identitcal to this one in my personal ledger file to split utilities with my girlfriend. From there I can run a simple report and copy and paste the results into an email once a month.

### Virtual Transactions

I wanted to mention another advanced ledger feature that I use every day. For various reasons I keep most of my money in my interest-paying checking account. I have most of it allocated away into various "funds", which are just fake buckets that only exist for me. It's the same idea as [ING subaccounts](http://www.getrichslowly.org/blog/2008/07/02/how-to-open-multiple-accounts-at-ing-direct/), but implemented in ledger instead of at the bank.

I've implemented these buckets using ledger's _virtual transaction_ feature. Basically, if you surround an account name in square brackets, ledger treats that portion of the transaction as _virtual_. Ledger will include this transaction in all reports unless you include the `--real` flag in your report command. Here's an example:

```bash
$ ledger bal checking
               $1000  Assets:Checking
```

Then, we insert this transaction:

```text
2011/12/01 * Establish Emergency Fund
    [Funds:Emergency]                    $500.00
    [Assets:Checking]
```
        
and run some more reports

```bash
 $ ledger bal checking funds
                 $500  Assets:Checking
                 $500  Funds:Emergency
 --------------------
                $1000
```

```bash
$ ledger --real bal checking funds
               $1000  Assets:Checking
```
        

### By our powers combined...

On their own, these two features are pretty useful. It's when you combine them that the awesome power of ledger starts appearing. As some of you may remember, I has a [bit of a medical emergency](/another-tiny-webapp) a few weeks ago and being a citizen of these great United States I have private insurance, so of course I'm going to be paying a not-inconsiderable sum out of pocket. How much? Only time will tell. I can't live like that though, I have to put some kind of structure to it or I'll go crazy. So, I looked up my [out of pocket maximum](http://healthinsurance.about.com/od/healthinsurancetermso/g/OOP_maximums_definition.htm) and carved out a portion of my emergency fund into a new medical fund:

```text
2011/12/18 * Establish Medical Fund
    [Funds:Medical]                    $4,000
    [Funds:Emergency]
```
        
I also added an automatic transaction that will withdraw from the medical fund whenever I record a medical expense:

```text
= /^Expenses:Medical/
    [Funds:Medical]                      -1.0
    [Assets:Checking]                     1.0
```
        
Putting it all together, adding a transaction like this:

```text
2011/12/18 * Corner Drug Store
    Expenses:Medical:OTC               $15.00
    Assets:Checking
```
        
Will result in these reports:

```bash
$ ledger reg funds:medical
11-Dec-01 Establish Medical Fund    [Funds:Medical]       $4000.00   $4000.00
11-Dec-18 Corner Drug Store         [Funds:Medical]        $-15.00   $3985.00
```

```bash
$ ledger reg checking
11-Nov-01 Checking Deposit          Assets:Checking      $10000.00  $10000.00
11-Dec-01 Establish Emergency Fund  [Assets:Checking]    $-5000.00   $5000.00
11-Dec-18 Corner Drug Store         Assets:Checking        $-15.00   $4985.00
                                    [Assets:Checking]       $15.00   $5000.00
```

```bash
$ ledger --real reg checking
11-Nov-01 Checking Deposit          Assets:Checking      $10000.00  $10000.00
11-Dec-18 Corner Drug Store         Assets:Checking        $-15.00   $9985.00
```
                                        
As you can see, the transaction for Corner Drug Store pulled $15 from `Assets:Checking` which was then automatically replaced from `Funds:Medical`. The virtual amount available in checking stays the same but the real amount goes down by $15 without any additional input. These two features combined let me spend directly from a virtual account while keeping track of everything for me.

If you go to the [Ledger website](http://www.ledger-cli.org) you can find the manual which has been recently greatly expanded and enhanced. There you'll see that the expression for an automated transaction can be much more advanced if you want it to be. Check it out.
