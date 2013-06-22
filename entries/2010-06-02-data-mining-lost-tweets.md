Title: Data Mining "Lost" Tweets Part 1
Date:  2010-06-02 17:45:00
Tags:  Programming, Perl
Id:    10

[twmine]:  http://gist.github.com/423346
[file]:    http://dl.dropbox.com/u/5193213/lost-finale-tweets.txt.gz
[twmine-capture]: http://gist.github.com/423346#file_capture_tweets.pl
[Twitter]: http://twitter.com
[twapi]:   http://apiwiki.twitter.com/Streaming-API-Documentation

*Note: this article uses the Twitter V1 API which has been shut down. The concepts still apply but you'll need to map them to the new V2 API.*

As some of you might know, [Twitter][] provides a [streaming API][twapi] that pumps all of the tweets for a given search to you as they happen. There are other stream variants, including a sample feed (a small percentage of all tweets), "Gardenhose", which is a stastically sound sample, and "Firehose", which is every single tweet. All of them. Not actually all that useful, since you have to have some pretty beefy hardware and a really nice connection to keep up. The filtered stream is much more interesting if you have a target in mind. Since there was such a hubbub about "Lost" a few weeks ago I figured I would gather relevant tweets and see what there was to see. In this first part I'll cover capturing tweets and doing a little basic analysis, and in the second part I'll go over some deeper analysis, including some pretty graphs!

--fold--

Capturing
---------

Let me preface: I have never watched a single episode of "Lost". When it started I had way too much stuff going on to pay attention to television and since then I've sort of conciously stayed away. I pass no judgements on anyone who is a fan or not, or who is evil or not.

The streaming API is pretty easy to work with. You basically give it a comma separated list of search terms and it will give you any and all tweets that match those terms. For example, if you were to run this command:

```bash
$ curl -q http://stream.twitter.com/1/statuses/filter.json\?track=bpcares \
    -uYourTwitterName:YourTwitterPass
```
    
you would get a stream of semi-humorous tweets about the oil spill.         
I wrote a little [perl wrapper][twmine-capture] around curl which will automatically stop capturing after a given number of hours or until it has captured a given number of megabytes. It will also reconnect when the stream dies for any reason. To capture a workable number of tweets, I launched this script on May 23rd at 4:14pm PDT like this:

```
$ capture-tweet-stream.pl 24 10000 ~/data/lost-finale-tweets.txt \
    'lost,locke,jack,sawyer,smokemonster,theisland,jacob,shepard'
```
        
This means, capture any tweets matching those terms for 24 hours or 10 gb, whichever comes first.

A little analysis
-----------------

For a while as I was running the capture I was tailing the output file and would pause the output whenever a gem of a tweet scrolled past, just so I could retweet it. Here's my favorite:

<blockquote class="twitter-tweet"><p>I hope Dexter shows up on Lost and kills them all. <a href="https://twitter.com/search?q=%23FuckLost&amp;src=hash">#FuckLost</a></p>&mdash; Ed Battes (@EdBattes) <a href="https://twitter.com/EdBattes/statuses/14592099261">May 24, 2010</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

I happen to be a fan of Dexter, and would have gladly paid money for a crossover. Anyway.

If you want to play along the data is on [my dropbox][file] and the code is all on [github][twmine]. First, let's get an idea of how much raw data we're working with. Twitter sends carriage-return separated JSON blobs. Awk to the rescue!

```bash
$ gzcat lost-finale-tweets.txt.gz | awk 'BEGIN{RS="\r"}{n+=1}END{print n}'
779750
$
```

Almost 780,000 tweets. Tweeps were busy! Ok, so what were they saying? A normal approach would be to run through all of the tweets and count up occurances of each word, but because there's so much output I can't do it on my laptop or I'd run out of memory. Instead, here's a map and two stage reduce process. The map is a fairly small perl script that everyone and their mother can pretty much write from memory, the word count mapreduce example:

```perl
#!/usr/bin/env perl

use strict;
use warnings;
use JSON::XS qw/ decode_json /;
use Try::Tiny;

$/ = "\r";
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

while(<>) {
    my $obj;
    try {
        $obj = decode_json($_);
    } catch { };

    next unless $obj;
    my $text = $obj->{text};
    next unless $text;
    $text =~ s/[^\w\d#\s]//g;
    my @w = split(/\s+/, lc $text);
    for my $i ( 0 .. $#w ) {
        print_if_all(1, $w[$i]);
        print_if_all(2, @w[$i..$i+1]);
        print_if_all(3, @w[$i..$i+2]);
    }
}

sub print_if_all
{
    my $n = shift;
    @_ = grep { $_ } @_;
    print join(' ', @_) . "\t1\n" if @_ == $n;
}
```

This one has a few modifications, though. First, it removes all punctuation except '#' and lowercases everything. Second, it will count each individual word as well as each two and three word phrase in the tweet. We can run it like this:

```bash
$ gzcat lost-finale-tweets.txt.gz | ./stem.pl | split -l 1000000 - output/out.txt
```

The reduce happens in two phases, both using this even smaller perl script that just sums the output from the first one:

```perl
#!/usr/bin/env perl

use strict;
use warnings;

my %sum;
binmode(STDIN, ':utf8');
binmode(STDOUT, ':utf8');

while(<>) {
    chomp;
    my ($key, $num) = split(/\t/, $_);
    $sum{$key} += $num;
}

print join("\t", $_, $sum{$_}) . "\n" for keys %sum;
```

Which we run like this:

```bash
$ find output -exec ./sum.pl {} \; | ./sum.pl | sort -t $'\t' -k 2,2nr > stems.txt
```

Sort of like a poor man's Hadoop, no? No, you're right. Not really. But it gets the job done, and that's what counts.
    
Ok, so now we have our word counts. Here's the top 26 words and phrases that people mentioned in these tweets after removing really common english words:

```text
lost	104181
#lost	53188
finale	25322
watching	11204
de lost	10475
tonight	9588
final	9107
lost finale	9101
series	9000
watch	8105
series finale	7487
the lost	7444
jack	5747
episode	5507
lost series	5062
end	4806
lost series finale	4696
watching lost	4179
the lost finale	3631
final de lost	3519
the end	2981
to watch	2964
watching the	2920
spoiler	2804
love	2768
the finale	2765
#lost finale	2579
```
    
In amongst all the tiny junk words, we have some really nice indicators that we can use in the next phase to filter to just the tweets that are actually talking about lost the tv show vs their lost kitten named Mittens. Interestingly, the phrase "you all everybody" only showed up 67 times. Sad.

