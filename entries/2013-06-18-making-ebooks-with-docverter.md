Title: Making eBooks with Docverter
Date:  2013-06-18 12:00:00
Id:    9b84f
Tags:  Docverter
Show_upsell: true

[mmp]: /mastering-modern-payments
[git]: /hosting-private-git-repositories-with-gitolite
[wiki]: /git-backed-personal-markdown-wiki
[page_viewer]: /page-viewer-a-simple-markdown-viewer
[docverter]: http://www.docverter.com
[fs]: http://code.google.com/p/flying-saucer/
[css paged media]: http://www.w3.org/TR/css3-page/
[css generated content]: http://dev.w3.org/csswg/css-gcpm/

I've been writing [my guide to integrating Stripe with Rails][mmp] using markdown, as with most textual projects that I work on. Every chapter is a markdown-formatted file living in a git repo, sycned-on-save to [my git server][git] and S3 [using SparkleShare][wiki]. When I want to peek at the rendered version I use little previewer app running on a VM on my Mac mini that I [talked about previously][page_viewer].

A good eBook needs a PDF version, of course. Awhile back I wrote a service named [Docverter][docverter] that can render XHTML to PDF using a library named [Flying Saucer][fs]. All you have to do is pipe in the HTML and other related files and you get back a rendered, self-contained PDF file. There are a few non-trivial aspects to this, of course, because HTML is not primarily intended for printable output. The W3C has worked up a [whole CSS module for page-related styles][css paged media] but it's not the most readable document. There's a few simple-ish things that you can do to your document to make it look nice, though.

--fold--

Here's the simplest HTML to PDF renderer:

```
require 'docverter'

Docverter.base_url = 'http://c.docverter.com'

html = <<HERE
<html>
  <head>
    <title>Test Document</title>
  </head>
  <body>
    <h1>Test Header</h1>
    <p>This is some text</p>
  </body>
</html>
HERE

File.open("out.pdf", "w+") do |f|
  f.write(Docverter::Conversion.run do |c|
    c.from    = 'html'
    c.to      = 'pdf'
    c.content = html
  end)
end
```

The HTML document is very simple, as is the conversion. `Docverter::Conversion.run` takes a block which yields a `Docverter::Conversion` object that can be set with any options Docverter supports. Most basically, you have to specify `from`, `to`, and `content`. If you run this program you'll get a file named `out.pdf`.

### Fonts

The first non-trivial thing that one would want to do is customize fonts. Flying Saucer knows quite a bit of CSS, including `@font-face`. All you have to do to customize fonts is to download the font as a `ttf` and modify the above program to look like this:

```
require 'docverter'

Docverter.base_url = 'http://c.docverter.com'

html = <<HERE
<html>
  <head>
    <title>Test Document</title>
    <style type="text/css">
      @font-face {
        font-family: 'Droid Sans';
        font-style: normal;
        font-weight: 400;
        src: url('droid_sans.ttf');
        -fs-pdf-font-embed: embed;
        -fs-pdf-font-encoding: Identity-H;
      }
      body {
        font-family: 'Droid Sans';
      }
    </style>
  </head>
  <body>
    <h1>Test Header</h1>
    <p>This is some text</p>
  </body>
</html>
HERE

File.open("out.pdf", "w+") do |f|
  f.write(Docverter::Conversion.run do |c|
    c.from    = 'html'
    c.to      = 'pdf'
    c.content = html

    c.add_other_file 'droid_sans.ttf'
  end)
end
```

A few interesting things are going on here. First, `@font-face` declares the font. `font-family` *must* match the name the font file specifies. Second, `-fs-pdf-font-embed` and `-fs-pdf-font-encoding` *must* match the values given above or the embedding won't work. `src` is the filename of the file, which we add to the conversion using `add_other_file`, which takes a path. Drop `droid_sans.ttf` in the same directory as the script and run it again. Notice that the PDF is now in Droid Sans, which is pretty pleasant.

### Footers

Most documents longer than a page are going to need page numbers. Adding page numbers to a PDF with Docverter is very much not trival. You need to combine the powers of CSS Paged Media running elements and [generated content][css generated content] to generate properly formatted footers with page numbers. Here's the HTML source:

```html
<html>
  <head>
    <title>Test Document</title>
    <style type="text/css">
      @font-face {
        font-family: 'Droid Sans';
        font-style: normal;
        font-weight: 400;
        src: url('droid_sans.ttf');
        -fs-pdf-font-embed: embed;
        -fs-pdf-font-encoding: Identity-H;
      }
      body {
        font-family: 'Droid Sans';
      }
      div.page_footer {
        display: block;
        text-align: center;
        font-family: 'Droid Sans';
        position: running(footer);
      }
      div.page_footer .page_number:after {
        content: counter(page);
      }
      @page {
        @bottom-center {
          content: element(footer);
        }
      } 
    </style>
  </head>
  <body>
    <div class="page_footer"><span class="page_number"></span></div>
    <h1>Test Header</h1>
    <p>This is some text</p>
  </body>
</html>
```

Three things to note here. First, the new `div` with class `page_footer` *has* to come before the rest of the body content because it gets moved into place as Flying Saucer renders. If it's at the bottom it won't exist when Flying Saucer tries to render the page and so nothing gets rendered at all.

Second, notice `position: running(footer)`. CSS Paged Media introduces the `running()` which tells the renderer to stick the content that's currently selected, in this case `div.page_footer`, into a slot named `footer`. We set up the page using the `@page` selector. Inside there is another selector named `@bottom-center`, which specifies the center section at the bottom of the page. The `content` attribute with an `element()` value tells the renderer to take the content from the slot named `footer` and use it to populate the section. Note that we could have named the `footer` slot anything. The named slots are in their own namespace separate from ids and classes.

Finally we get to actually setting up the page number. There's a default counter named `page` which we put after the span with class `page_number` using CSS generated content.

### Page Breaks

PDFs are effectively pre-printed documents, so CSS Paged Media gives you a few different facilities for controlling page breaks. For example, if I wanted a page break before every `H1` element I could say this:

```css
h1 {
  page-break-before: always;
}
```

If, instead, I want to break after a certain element, like a closing paragraph or something, I could do this:

```css
p.closing {
  page-break-after: always;
}
```

Sometimes you have elements that you want to not break across pages if at all possible. In Mastering Modern Payments there are dozens of code examples that, if I let Flying Saucer break at the natural spots, would have one or two lines on one page and the rest of the 10-line sample on the other. CSS Paged Media lets you control that, too, with `page-break-inside`. Here's the rule I use:

```css
code {
  page-break-inside: avoid;
  orphans: 0;
  widows: 0;
}
```

This says to avoid inserting page breaks inside a code block. The `orphans` option controls how many lines are allowable at the bottom of a page inside a block and `widows` controls how many are allowed at the top of the next. By setting both to `0` I'm saying that I don't want any page breaks at all. Flying Saucer will ignore me if it's not possible, if for instance I have a code block that spans more than an entire page.

<hr>

Making nice-looking PDFs with HTML source is not trivial. It would probably end up being easier to just drop the raw text inside Apple's iBooks Creator and style it that way, but I like a challenge. It's already looking pretty nice, and with a little more work I think I can have professional-grade PDF output. Now, to actually finish writing the book.
