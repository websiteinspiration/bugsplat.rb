---
title: 'Tiller, Ledger, and Sorbet'
id: tlsrb
topic: Software
tags: Personal Finance, Software
---

## Tiller + Ledger

Thirteen years ago I started tracking my finances using a tool named [Ledger](https://ledger-cli.org).
Up until 2018 I hand-entered every penny into my ledger files, which absolutely had value but eventually I decided that I wanted to automate things as much as I could.

I happened upon [Tiller](https://www.tillerhq.com) which scrapes bank accounts and puts the data into a Google spreadsheet.
Importantly, Tiller adds a unique ID to every transaction it sees, which means if I want to automate something I don't have to try to implement deduplication.

Back in 2018 the script I used was rough, but I've polished it over the years and, just the other day, published the guts as [`LedgerTillerExport`](https://github.com/peterkeen/ledger_tiller_export).

The gem consumes a set of reconciliation rules and a Google spreadsheet ID and produces a set of ledger transactions.
Rules are given a row from the spreadsheet and return the correct account name for that transaction. For example, I can create a rule like this:

```ruby
rule = LedgerTillerExport::RegexpRule.new(
  match: /Kroger/i,
  account: 'Expenses:Food:Groceries',
)
```

This rule looks for `/Kroger/` in a Tiller payee line and says that that is always the `Expenses:Food:Groceries` expense account, like this:

```
2020-05-21 * Kroger
   ; tiller_id: 5323ch323466234c3467
   Expenses:Groceries                  $150.00
   Liabilities:CreditCard
```

I can create custom rules that do more complicated things than just a regular expression match.
There's a rule in the readme that shows how I reconcile checks, for example.

Where does this `tiller_id` thing come in, you ask?
`LedgerTillerExport` generates a list of known `tiller_id`s by querying `ledger` like this:

```
ledger --register-format='%(tag("tiller_id"))\n' reg expr 'has_tag(/tiller_id/)'
```

This extracts the value of the `tiller_id` tag for every transaction that has one applied.
In Ruby we then split the value on commas because I have a bunch of transactions where I've collapsed multiple Tiller rows into one Ledger transaction by hand.

## Sorbet

Ok, so, that's interesting, but I also want to talk about [Sorbet](https://sorbet.org).

I started working at Stripe almost a year ago and met the Sorbet type checker on my first day.
Despite a few warts I've come to adore this way of working with types in Ruby.
Both `LedgerTillerExport` and `LedgerGen`, my library for building ledger transactions, are built using Sorbet.

My favorite thing in Sorbet is `T::Struct`.
This lets you define a typed record that you can then pass around to functions and serialize to json.
For example, here's a struct from `LedgerTillerExport`: 

```ruby
class Row < T::Struct
  extend T::Sig

  const :txn_date, Date
  const :txn_id, String
  const :account, String
  const :amount, Float
  const :description, String

  sig {params(row: T::Hash[String, T.nilable(String)]).returns(Row)}
  def self.from_csv_row(row)
    new(
      txn_date: Date.strptime(T.must(row["Date"]), "%m/%d/%Y"),
      txn_id: T.must(row['Transaction ID']),
      account: T.must(row['Account']),
      amount: T.must(row["Amount"]).gsub('$', '').gsub(',', '').to_f,
      description: T.must(row['Description']).gsub(/\+? /, '').capitalize,
    )
  end
end
```

We create `Row`s from the Tiller spreadsheet's `CSV` rows.
Every row consists of five fields, all defined as `const` which guarantees that nothing can change those fields once we've called `new`.

We can then pass a `Row` instance around in our program and lean on the static typechecker and runtime to ensure that we're using it correctly everywhere.

My only problem with `T::Struct` is that you can't subclass one due to limitations in the typechecker.
If you want the `prop`/`const` behavior but you don't necessarily care about the other guarantees that `Struct` gives you you can either subclass `T::InexactStruct` or include a few modules:

```ruby
class NotQuiteAStruct
  include T::Props
  include T::Props::Constructor

  prop :something, String
  const :something_else, String
end

NotQuiteAStruct.new(something: 'abc', something_else: 'def')
```

I use this in a couple places in `LedgerTillerExport`, namely for `RegexpRule` and `Exporter` to make them easily subclassable.

There are lots of other things to like about Sorbet.
Method signatures, the typechecker is super fast, etc.

If you follow the rules Sorbet eliminates entire classes of tests that one would otherwise have to write to guarantee your program is correct.
