Title: A Robust Reporting System for Ledger
Date:  2012-01-01 10:01:14
Tags:  Personal Finance, Ledger, Projects, Ruby
Id:    3a32a

*Note: you can find much more information about ledger on [ledger-cli.org](http://ledger-cli.org), including links to official documentation and other implementations*

For the last five years I've kept my personal finances in order using the ledger system, a sophisticated command line program that consumes a lightly formatted text file. It's helped me repay debts and get everything in order, helping me financially absorb an injury last month that would have been extremely detrimental just a few years prior.

The stock ledger program is exclusively command-line oriented. For quick checks and `grep`ing over output, this is fine. For some time, though, I've wanted a more graphical, more robust way of looking at my finances. I've also wanted a more familiar query language, since version 2.0's queries were someone limited and version 3.0's query syntax is not very well documented yet. Last year I wrote a [simple system](/program-your-finances-reporting-for-fun-and-profit) that pushed monthly reports out to static HTML files, which got me part of the way there but I really wanted something more flexible. Something where I can just write an arbitrary query and have the output dumped to HTML.

Thus, I present [Ledger Web](https://github.com/peterkeen/ledger-web). In Ledger Web, your ledger is kept in a text file, just the same as always, reports are ERB files, and queries are SQL. Ledger Web watches your ledger file and whenever it changes dumps it into a PostgreSQL database table. It's also quite customizable, letting you set hooks both before and after row insertion and before and after ledger file load.

--fold--

### Installation

Ledger Web installation is pretty simple. First make sure you have PostgreSQL version 9.0 or greater installed on your machine. Then, run these commands:

```bash
$ gem install ledger_web
$ createdb ledger
$ ledger_web
```

Then, open your web browser to [http://localhost:9090/](http://localhost:9090/) where you'll see some simple example reports. 

### Example Report

Let's walk through a simple pair of reports that shows off most of Ledger Web's features. Yesterday I ran across this [blog post](http://earlyretirementextreme.com/your-budget-is-like-sinking-ship.html) which draws a comparison between a typical person's budget and a wooden ship, always springing leaks and at risk of sinking to the bottom. I decided to write a report that shows my expenses both summed by year and broken out into individual lines. First, the Leaky Ship report itself:

```erb
<% @query = query({:pivot => "Year"}) do %>
select
    account as "Account",
    xtn_year as "Year",
    coalesce(sum(amount), 0) as "Amount"
from
    accounts_years
    left outer join (
        select
            xtn_year,
            account,
            amount
        from
            ledger
    ) x using (account, xtn_year)
where
    account ~ '(Income|Expenses)'
    and xtn_year <= date_trunc('year', cast(:to as date))
group by
    account,
    xtn_year
order by
    account,
    xtn_year
<% end %>
<div class="page-header">
  <h1>Leaky Ship</h1>
</div>
<%= table(@query, :links => {/\d{4}-\d{2}-\d{2}/ =>
    '/reports/register?account=:0&year=:title'}) %>
```

It starts off with a database query, defined using a helper named `query`. It uses a table named `ledger`, which is where your ledger data will be dumped, as well as a view named `accounts_years`, which is the cross product of every account by every year. This makes sure that rows show up properly even if there's no data for that particular year. Also, it uses `:pivot => "Year"`, which will *pivot* the report such that each `xtn_year` will become it's own column.

The `:to` param in the `where` clause is automatically populated with the second date in the range at the top of all reports.

Next, it uses some basic [Twitter Bootstrap](http://twitter.github.com/bootstrap) HTML markup to display a nice title, and then uses the `table` helper to actually dump the query results to an HTML table. The `:links` option tells the `table` helper to link the values in any column who's title matches the regular expression `/\d{4}-\d{2}-\d{2}/` to `/reports/register?account=:0&year=:title`, where `:0` will get replaced with the value in column 0 (starting from the left, 0 indexed) and `:title` will be replaced by the title of the column.

Here's a screenshot of what this report looks like (Note: this uses the Stan example ledger that I generated for my previous reporting system):

<a href="http://files.bugsplatcdn.com/files/5f017c22b146e19d6c1a/leaky_ship.png"><img class="thumbnail" src="http://files.bugsplatcdn.com/files/1ec86c1079d7aef07aff/leaky_ship_small.png"></a>

The register report that Leaky Ship links to is pretty trivial in comparison. Here's the source:

```erb
<% expect ['account', 'year'] %>
<% @query = query do %>
   select
       xtn_date as "Date",
       account as "Account",
       note as "Payee",
       amount as "Amount"
   from
       ledger
   where
       xtn_year = :year
       and account = :account
   order by
       xtn_date
<% end %>
<div class="page-header">
  <h1>Register</h1>
</div>
<%= table @query %>
```

The only thing new that this does is use the `expect` helper to ensure that `account` and `year` are query params. If they are not, `expect` throws an exception rather than showing bad data. Here's what this one looks like:

<a href="http://files.bugsplatcdn.com/files/f8ca9831fc1be3388c09/register.png"><img class="thumbnail" src="http://files.bugsplatcdn.com/files/c33219c7fa541dda453e/register_small.png"></a>

Both of these reports, as well as a few others, can be found in [my Ledger Web configuration](https://github.com/peterkeen/ledger-web-config). My config also shows off some of the more advanced customizations you can do.

The [README](https://github.com/peterkeen/ledger-web) goes into much more detail on how the helpers work and the various config settings work. Please, install it and let me know what you think!
