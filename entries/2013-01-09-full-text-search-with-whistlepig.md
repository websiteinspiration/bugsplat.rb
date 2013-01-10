Title: Full Text Search with Whistlepig
Date:  2013-01-09 07:51:11
Id:    6d23b
Tags:  Programming, Meta

Yesterday I suddenly developed the intense need to add search to this site. Among the problems with this is that the site is kind of a weird hybrid between static and dynamic, and it has no database backend. If posts were stored in Postgres this would be a trivial matter, but they're just markdown files on disk. After flailing around for awhile I came across a library named [Whistlepig][] which purported to do in-memory full text indexing with a full query language.

[Whistlepig]: http://masanjin.net/whistlepig/

--fold--

### First pass: Regular expressions

To rewind a bit, my first horrible stab at search was to find all of the posts that matched a user-provided regular expression:

    @results = @posts.find_all do |post|
      post.body.match /\b#{user_query}\b/
    end

This is of course complete madness. Not only am I allowing the user to put whatever they want in a regex but it only matches whole words. Not to mention that, while I only have around sixty pages right now, that number's never going to go down.

### Other Solutions

There's a bunch of different hosted and external options that I briefly considered, none of which were very satisfactory.

* `sqlite3` has built-in FTS but I would have to build a bunch of stuff around it.
* [xapian][] is a FTS engine but like with `sqlite3` I'd have to build stuff.
* `elasticsearch` would work but it's an external process that I'd have to run and it's an awful lot of overhead
* Some kind of hosted `elasticsearch` or `solr` provider would work, but again lots of overhead and not free and I'm then dependent on their uptime.

### Whistlepig to the Rescue

[Whistlepig][] is a small text search index. Small as in not very many features and not much code, but the features that are there are perfect for my needs:

* Full query language
* In-memory, in-process
* Arbitrary number of indexes for the same document

Here's a full example of how to index and query a document:

    require 'rubygems'
    require 'whistlepig'

    document = "Hi there"

    index = Whistlepig::Index.new "index"

    entry = Whstilepig::Entry.new
    entry.add_string "body", document

    docid = index.add_entry entry

    query = Query.new("body", "hi")
    result = index.search(query)
    assert_equal docid, result[0]

The [indexing code][] in bugsplat's app is not much more complicated. Here's the interesting bit:

    @pages_by_docid = {}

    @pages.each do |page|
      entry = Whistlepig::Entry.new

      entry.add_string "body", page.render(@strip_renderer)
      entry.add_string "name", page.name
      entry.add_string "title", page.title.downcase
      entry.add_string "tags", page.tags.join(" ").downcase
      entry.add_string "page_id", page.page_id
      entry.add_string "blog_post", page.is_blog_post? ? "yes" : "no"
      docid = @index.add_entry(entry)

      @pages_by_docid[docid] = page
    end

In bugsplat a `Page` encapsulates everything about an entry writen in Markdown. I maintain six indexes on the pages, including `body` rendered with a [Markdown-stripping, downcasing renderer][stripper], `name` which is the canonical name of the post, `title`, `tags`, `page_id` which is a short-code type of thing, and `blog_post` which is a simple boolean as to whether the post has a date or not.

"Why so many indexes?" you may find yourself asking. Because instead of just implementing search and being done with it, I went and refactored the guts of the blog to use it throughout. See, I had these terrible little things everywhere, all over the place:

    @page = @pages.find_all { |p| p.has_tag? params[:tag] }

Doing linear searches across the list of in-memory pages isn't *too* terrible but man it bugged me to have to repeat that everywhere. Instead of that, I can do nice things like this:

    @tagged_pages = @pages.search(params[:tag].downcase, "tags")

Each time I found myself iterating over all of the pages to get a subset I replaced it with a search query. The code is much nicer to read and faster, although almost all of it is cached as static HTML in production.

### Try it out!

Go ahead and search for some stuff and let me know what you think! And next time you find yourself with a full text search problem, see if Whistlepig would help you out. It's not for everybody, but it's very good at what it does.

[indexing code]: https://github.com/peterkeen/bugsplat.rb/blob/master/page.rb#L33
[stripper]: https://github.com/peterkeen/bugsplat.rb/blob/master/strip_renderer.rb
[xapian]: http://xapian.org/