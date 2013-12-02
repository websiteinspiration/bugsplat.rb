Title: Simulating a Market in Ruby
Id:    sim
Tags:  Programming

Trading markets of all kinds are in the news pretty much continuously. The flavor of the week is of course the Bitcoin markets but equity and bond markets are always in the background. Just today there is an article on Hacker News about [why you shouldn't invest in the stock market](http://edmarkovich.blogspot.com/2013/12/why-i-dont-trade-stocks-and-probably.html). I've participated in markets in one way or another for about a decade now but I haven't really understood how they work at a base level. Yesterday I built a [tiny market simulator](https://github.com/peterkeen/trading) to fix that.

--fold--

## Basic Concepts

**tl;dr**: a market for a commodity is two sorted lists, one of prices someone is willing to pay and another of prices is willing to accept.

A market exists to enable people to trade something, whether that be shares of stock or pork futures contracts or cryptocurrency tokens. In modern markets the fundamental core is called the **order book**. This is an open listing of offers to buy and sell a given commodity at some price. For example:

* Pete has 10 shares of TSLA and is willing to sell them at $10 per share
* Andrew would like to buy 10 shares of TSLA and is willing to pay $9.99 per share

The order book looks like this:

<table class="table table-condensed table-striped table-bordered">
  <thead>
    <tr>
      <th>Buy</th>
      <th>Sell</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>10 @ $9.99</td>
      <td>10 @ $10.00</td>
    </tr>
  </tbody>
</table>

Emily can see the order book because it's public and open. She also has 10 shares of TSLA and decides to match Andrew's bid. She puts in a sell order at $9.99. Now the order book looks like this:

<table class="table table-condensed table-striped table-bordered">
  <thead>
    <tr>
      <th>Buy</th>
      <th>Sell</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>10 @ $9.99</td>
      <td>10 @ $9.99</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>10 @ $10.00</td>
    </tr>
  </tbody>
</table>

Hold on for a second. Why did Emily's offer bump Pete's down in the list? Each column of the order book is sorted by *price* and then by *time*. Buy orders are sorted highest price first, sell orders are sorted lowest first.

Trades only happen at the top of the order book. Because there's a match at the top of the order book the market executes the trade. Emily and Andrew exchange $9.99 for 10 shares of TSLA and Pete is left waiting for another suitor to come along and match his price.

This is how the notional price of an equity or contract is determined by the market. Each time a trade happens that price gets broadcast to the world as *the* price.

These orders are called *limit orders* because they say "buy TSLA for $9.99 but *no more*" or "sell TSLA for $10 but *no less*." In our example, if Fred didn't look at the book and decides to put in a buy for $10.05, he'll get his 10 shares at $10.00 from Pete.

Limit orders are the fundemental building block of a market. There are other order types but they're almost always built using one or more limit orders. One notable exception is a *market* order which orders a specific quantity at whatever the current market price is. (thanks for the corrections, [minimax](https://news.ycombinator.com/item?id=6834599)!)

## Building a Simulation

Almost all of the above I learned by reading articles about basic trades and actually building a simulation. I decided to practice [readme driven development](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) and test driven development for this project, mainly because RDD helps me organize my thoughts and TDD helps me keep the programming going in the right direction. My first pass at the simulation was... well I guess you could say terrible. I completely misunderstood how the order book worked so I built this thing where *any* price match would execute a trade, not just at the top of the book. You can see that in [the first working commit of my simulator](https://github.com/peterkeen/trading/tree/f713308de2965df20a335e192dbf2c15648fe301).

After thinking about the problem really hard and reading about how order books are actually supposed to work I did some research and came across the [algorithms](https://github.com/kanwei/algorithms) gem. Among other awesome things, this gem includes several implementations of a data structure named the [Red Black Tree](http://en.wikipedia.org/wiki/Red%E2%80%93black_tree). This structure keeps it's keys sorted during insert and removal, which is perfect for the order book. Each order book consists of a pair of these tree maps, one for buy and one for sell. The keys are the actual [Order object](https://github.com/peterkeen/trading/blob/master/lib/trading/order.rb) and the value is just `true`, since we only really care about the keys.

The core of the simulation is submitting orders and checking to see if there's a match. Submitting is fairly trivial:

```ruby
def submit_order(order)
  if order.order_type == :buy
    buy_map.push(order, true)
  else
    sell_map.push(order, true)
  end
end
```

Because the book is kept sorted, determining a match is also relatively straightforward. Here's the code in the book:

```ruby
def match?
  return false if buy_map.size == 0 || sell_map.size == 0
  sell_map.min_key.match? buy_map.max_key
end
```

We just have get the top of each column in the order book and compare them. The tree map takes care that we can efficiently get both the min and max key.

Here is the implementation of `Order#match?`:

```ruby
def match?(other)
  price_match = if order_type == :buy && other.order_type == :sell
    price >= other.price
  else
    price <= other.price
  end
  
  commodity == other.commodity &&
    quantity == other.quantity &&
    price_match
end
```

We first determine how to compare the price and then do some sanity checking on commodity and quantity. This simulator is limted to trading orders of exactly the same quantity but real markets can fulfill orders in more complicated ways.

## Learning

So what did I learn yesterday afternoon? A few things. First, readme driven development and test driven development go hand in hand when building a project like this. Writing (and rewriting) the readme helped to clarify what I actually wanted to build, and writing tests both before and after building the implementation helped immensely with keeping the goal clear and my implementation correct.

Second, I gained a *much* better understanding of how markets work on a basic level. Actually getting in and building something seems to cement the ideas a whole lot better than just reading about them.
