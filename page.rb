Encoding.default_internal, Encoding.default_external = ['utf-8'] * 2

require 'rubygems'
require 'redcarpet'
require 'date'
require 'whistlepig'
require 'redcarpet'

class Pages

  attr_reader :pages_by_docid, :pages
  
  def initialize
    setup_renderers
    parse_all
  end

  def setup_renderers
    @normal_renderer = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML, :fenced_code_blocks => true)
    @strip_renderer = Redcarpet::Markdown.new(
      StripRenderer, :fenced_code_blocks => true)
    @index = Whistlepig::Index.new("index")
  end

  def parse_all
    @pages = find_all_files.map do |page|
      Page.new(Page.normalize_name(page), @normal_renderer)
    end

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

      page.docid = docid
      @pages_by_docid[docid] = page
    end
  end

  def find_all_files
    Dir.glob(File.join(File.dirname(__FILE__), "entries", "*.md")).map do |fullpath|
      File.basename(fullpath)
    end
  end

  def search(query_text, part="body", sort=:date)

    begin
      query = Whistlepig::Query.new(part, query_text)
    rescue Whistlepig::ParseError => e
      puts "error: #{e}"
      return []
    end

    docids = @index.search(query)

    results = docids.compact.map do |docid|
      @pages_by_docid[docid]
    end

    results.compact.sort_by { |p| p.send(sort) }
  end

  def blog_posts(sort_by=:date)
    search("yes", "blog_post")
  end

  def each
    @pages.each do |page|
      yield page
    end
  end

  def tag_frequencies
    tags = Hash.new(0)
    @pages.each do |page|
      page.tags.each do |tag|
        tags[tag] += 1
      end
    end
    tags
  end

  def related_posts(target)
    freqs = tag_frequencies
    
    highest_freq = freqs.values.max
    related_scores = Hash.new(0)

    blog_posts.each do |post|
      post.tags.each do |tag|
        if target.tags.include?(tag) && target != post
          tag_freq = freqs[tag]
          related_scores[post] += (1 + highest_freq - tag_freq)
        end
      end
    end

    related_scores.sort do |a,b|
     if a[1] < b[1]
          1
        elsif a[1] > b[1]
          -1
        else
          b[0].date <=> a[0].date
        end
    end.select{|post,freq| freq > 1}.collect {|post,freq| post}
  end
end

class Page

  DATE_REGEX = /\d{4}-\d{2}-\d{2}/
  SHORT_DATE_FORMAT = "%Y-%m-%d"
  DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

  attr_accessor :docid
  attr_reader :name, :body

  def initialize(page, renderer)
    @name = page
    @renderer = renderer
    parse_page
  end

  def parse_page
    headers, body = contents.split(/\n\n/, 2)
    parse_headers(headers)
    parse_body(body)
  end

  def parse_headers(header_text)
    @headers = {}
    header_text.split("\n").each do |header|
      name, value = header.split(/:\s+/, 2)
      @headers[name.downcase] = value
    end
  end

  def parse_body(body_text)
    @before_fold, after_fold = body_text.split("--fold--")
    @body = body_text.sub("--fold--", '')
  end

  def self.normalize_name(page)
    return page.downcase.strip.sub(/\.(html|md|pdf)$/,'')
  end

  def is_blog_post?
    return @name =~ DATE_REGEX
  end

  def render(renderer=nil)
    (renderer || @renderer).render(@body)
  end

  def render_before_fold
    @renderer.render(@before_fold)
  end

  def contents
    @contents ||= File.open(filename, 'r:utf-8') do |file|
      file.read
    end
  end

  def filename
    File.join(File.dirname(__FILE__), "entries", "#{@name}.md")
  end

  def matches_path(path)
    normalized = self.class.normalize_name(path)
    return @name == normalized || @headers['id'] == normalized
  end

  def [](key)
    return @headers[key]
  end

  def tags
    if @headers.has_key?('tags')
      return @headers['tags'].split(/,\s+/)
    else
      return []
    end
  end

  def has_tag(tag)
    tags.detect { |t| t == tag }
  end

  def title
    @headers['title']
  end

  def page_id
    @headers['id']
  end

  def date
    if is_blog_post?
      if @headers['date']
        Time.strptime(@headers['date'], DATE_FORMAT)
      else
        Time.strptime(@name, SHORT_DATE_FORMAT)
      end
    end
  end

  def natural_date
    date ? date.strftime("%A, %e %B %Y") : ''
  end

  def html_path
    "/#{@name}"
  end

  def pdf_path
    "/#{@name}.pdf"
  end

  def docx_path
    "/#{@name}.docx"
  end

  def markdown_path
    "/#{@name}.md"
  end

  def docverter_markdown
"""% #{@headers['title']}
%
% #{natural_date}

#{@body}
"""
  end
end
