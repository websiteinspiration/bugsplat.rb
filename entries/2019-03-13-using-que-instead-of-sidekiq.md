---
title: Using Que instead of Sidekiq
id:    f17ad
tags:  programming
topic: Programming
description: "Sidekiq is awesome but sometimes alternatives make more sense."
---

A project I've had on the back burner for quite awhile is my own little marketing automation tool.
Not that existing tools like Drip or ConvertKit aren't adequate, of course.
They do the job and do it well.

I enjoy owning my own infrastructure, however, and after Drip changed direction and raised prices I found myself without a home for my mailing list.
I thought, why not now?

One vital component of any broadcast email system is **fanout**, where you merge the message you want to send with the list of people that should receive it.
The easiest way to fanout is to just loop over the list of recipients and enqueue a job for each:

```ruby
Contact.not_opted_out.each do |contact|
  BroadcastMessageDeliver.perform_async(contact.id, the_message.id)
end
```

This is simple and works great. However, it's not super efficient. We can do better.

If we're using Sidekiq we can use `push_bulk`:

```ruby
Contact.not_opted_out.find_in_batches do |batch|
  Sidekiq::Client.push_bulk(
    class: 'BroadcastMessageDeliver', 
    args: batch.map { |c| [c.id, the_message.id] }
  )
end
```

The `find_in_batches` call is a built-in ActiveRecord method that will give you all of the records in the scope in batches, which is just an array of ActiveRecord objects.
`Sidekiq::Client.push_bulk` eliminates the vast majority of Redis round trips that the naive version does because it pushes the whole batch in one Redis call.

We can still do better, though. Instead of using Sidekiq we can use [Que](https://github.com/chanks/que).
Que is a background processing system like Sidekiq that keeps jobs in a PostgreSQL table instead of in a Redis list.
It uses PostgreSQL's native `listen/notify` system to make job starts basically instantenous, rather than polling like what `DelayedJob` does.

Using the database as the queue has a number of advantages over systems that use two data stores. In particular, ACID guarantees and atomic backups are important to me because I'm running this all myself. The fewer moving parts the better.

The other thing you can do is **insert directly into the `que_jobs` table**:

```ruby
ActiveRecord::Base.connection.execute(%Q{
  INSERT INTO que_jobs (job_class, args)
  SELECT
    'BroadcastMessageDeliver' as job_class,
    jsonb_build_array(#{the_message.id}, x.id) as args
  FROM
    (#{Contact.not_opted_out.select(:id).to_sql}) x
})
```

The `que_jobs` table is just a database table, which means you can insert into it however you want.
For example, `Que::Job.enqueue` just creates a record and saves it, it doesn't use any ActiveRecord hooks at all.

We can eliminate almost every round trip and application-level loop by letting the database do all the work.

Benchmarks (local Redis and local PostgreSQL, 5000 records):

* Sidekiq loop: 1.9 seconds
* Sidekiq batches: 0.3 seconds
* **Que direct insert: 0.7 seconds**

Wait... that's... slower?

I'm as surprised as you are, but there turns out to be a pretty good reason.
Que performs a bunch of check constrants on the incoming data to make sure it's coherent and ready to run. Here's all the things it checks:

```
Check constraints:
    "error_length"
    "job_class_length"
    "queue_length"
    "valid_args"
    "valid_data"
```

`valid_data` in particular does a handful of expensive-ish operations on the incoming `json` data.

So I guess the lesson here is to always validate your assumptions.
I assumed that eliminating round trips would make things faster but because of other constraints and validations it's actually slower.

Still, it's considerably faster than the naive version (which is still no slouch, let's be honest), my marketing system gets all those in-database queue benefits, and I find it aesthetically pleasing. I think I'll keep it.
