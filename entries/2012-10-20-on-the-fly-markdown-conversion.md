---
title: On-the-fly Markdown Conversion to PDF and Docx
date: '2012-10-20 12:21:33'
id: 46c44
tags: Docverter, Programming, Meta
topic: Software
description: How to convert markdown content into other formats using Docverter.
---

Today I added PDF, Docx, and Markdown download links to the bottom of every post here on Bugsplat.
Scroll down to the bottom to see them, the scroll back up here to read how it works.

--fold--

For the past few weeks I've been working on a product named [Docverter][], which does on-the-fly
plain text to rich text formatting in a variety of formats with a simple HTTP API. I write entries
on this blog in Markdown, which makes it a natural candidate for these types of conversions. Simplified,
the code boils down to this:

```ruby
Docverter.api_key = "<API-KEY>"

result = Docverter::Conversion.run do |c|
  c.from     = 'markdown'
  c.to       = 'pdf'
  c.content  = 'page content'
  c.template = 'template_filename.html'

  c.add_other_file 'template_filename.html'
end
```

`result` is the string of the converted PDF or Docx from Docverter. `template_filename.html` is a simple HTML
template that Docverter plugs the HTML that results from the Markdown into before sending it to the HTML to PDF
converter. The Docx conversion code is very similar but uses a different template and `to` format. All of the options
are documented in the [API docs][], but that's basically all you need to get started converting Markdown to PDF.

Just for kicks I added the Markdown download so it's easy to see what exactly bugsplat uses as input. The icon comes
from the [Markdown-mark][] project.

[Docverter]: http://www.docverter.com
[API docs]: http://www.docverter.com/api.html
[Markdown-mark]: https://github.com/dcurtis/markdown-mark
