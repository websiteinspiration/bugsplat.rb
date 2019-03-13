Encoding.default_internal, Encoding.default_external = ['utf-8'] * 2

require 'rubygems'
require 'redcarpet'
require 'date'
require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'


class HTMLwithRouge < Redcarpet::Render::HTML
  include Rouge::Plugins::Redcarpet # yep, that's it.

  def postprocess(document)
    document.gsub('&#39;', "'")
  end
end

class Pages

  attr_reader :pages, :non_blog_posts, :renderer
  
  def initialize
    @pages_by_page_name = {}
    @pages_by_page_id = {}
    @pages_by_tag = {}
    @pages_by_topic = {}
    @blog_posts = []
    @non_blog_posts = []

    setup_renderer
    parse_all
  end

  def setup_renderer
    @renderer = Redcarpet::Markdown.new(
      HTMLwithRouge, :fenced_code_blocks => true)
  end

  def parse_all
    @pages = find_all_files.map do |page|
      next if File.basename(page).start_with?('_')
      pg = Page.new(page, @renderer)
      next if pg.headers['draft'] && ENV['RACK_ENV'] == 'production'
      pg
    end.compact

    @pages.each do |page|
      @pages_by_page_name[page.name] = page
      @pages_by_page_name[page.original_name] = page
      @pages_by_page_id[page.page_id] = page
      if page.topic
        topic = page.topic.downcase
        @pages_by_topic[topic] ||= []
        @pages_by_topic[topic] << page
      end

      page.alternate_links.each do |link|
        @pages_by_page_id[link] = page
      end

      page.tags.each do |tag|
        @pages_by_tag[tag.downcase] ||= []
        @pages_by_tag[tag.downcase] << page
      end

      if page.is_blog_post?
        @blog_posts << page
      else
        @non_blog_posts << page
      end
    end
  end

  def find(thing)
    @pages_by_page_id[thing] || @pages_by_page_name[thing]
  end

  def tagged(tag)
    (@pages_by_tag[tag.downcase] || [])
  end

  def find_all_files
    basepath = File.join(File.dirname(__FILE__), "entries")
    Dir.glob(File.join(basepath, "**/*")).map do |fullpath|
      next if File.directory?(fullpath)
      fullpath.gsub(basepath + "/", '')
    end.compact
  end

  def each
    @pages.each do |page|
      yield page
    end
  end

  def topics
    @pages_by_topic.keys.sort
  end

  def tags
    @pages_by_tag.keys.sort
  end

  def for_topic(topic)
    @pages_by_topic[topic].sort
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

  def blog_posts
    @blog_posts.sort { |a, b| a.date <=> b.date }
  end
end

class Page

  DATE_REGEX = /\d{4}-\d{2}-\d{2}/
  SHORT_DATE_FORMAT = "%Y-%m-%d"
  DATE_FORMAT = "%Y-%m-%d %H:%M:%S"

  attr_accessor :docid
  attr_reader :name, :original_name, :body, :original_filename, :original_body, :headers

  def initialize(filename, renderer)
    @file = filename
    @original_filename = filename
    @original_name = self.class.normalize_name(filename, false)
    @name = self.class.normalize_name(filename)
    @renderer = renderer
    parse_page
  end

  def parse_page
    if contents =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
      @headers = YAML.load($1)
      parse_body($3)
    end
  end

  def parse_body(body_text)
    @original_body = body_text
    @before_fold, after_fold = body_text.split("--fold--")
    @body = body_text.sub("--fold--", '')
  end

  def self.normalize_name(page, strip_date=true)
    name = page.downcase.strip.sub(/\.(html|md|pdf)(\.erb)?$/,'')
    if strip_date
      name = name.sub(/\d{4}-\d{2}-\d{2}-/, '')
    end
    name
  end

  def is_blog_post?
    return filename =~ DATE_REGEX
  end

  def render(renderer=nil, app=nil)
    content = is_erb? ? render_erb(@body, app) : @body
    if is_html?
      content
    else
      (renderer || @renderer).render(content)
    end
  end

  def render_erb(content, app)
    template = ERB.new(content)
    @app = app
    template.result(binding)
  end

  def is_erb?
    original_filename.end_with?('.erb')
  end

  def is_html?
    original_filename =~ /\.html(\.erb)?$/
  end

  def id_matches?(id)
    links = alternate_links + [self.page_id]
    links.include? id
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
    File.join(File.dirname(__FILE__), "entries", @file)
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

  def alternate_links
    if @headers.has_key?('alternate_links')
      return @headers['alternate_links'].split(/\s+/)
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
        Time.strptime(@file, SHORT_DATE_FORMAT)
      end
    elsif @headers['date']
      Time.strptime(@headers['date'], SHORT_DATE_FORMAT)
    else
      Date.today
    end
  end

  def <=>(other)
    if self.date && other.date
      self.date <=> other.date
    else
      self.title <=> other.title
    end
  end

  def reading_time
    ([body.split(/\s+/).length / 180.0, 1].max).to_i
  end

  def natural_date
    date ? date.strftime("%e %B %Y") : ''
  end

  def short_date
    date ? date.strftime("%e %b %Y") : ''
  end

  def mtime
    File.mtime(filename)
  end

  def topic
    headers['topic']
  end

  def html_path
    "/#{@name}"
  end

  def pdf_path
    "/#{@name}.pdf"
  end
p
  def markdown_path
    "/#{@name}.md"
  end

  def view
    @headers.has_key?('view') ? @headers['view'].to_sym : nil
  end

  def layout
    @headers.has_key?('layout') ? @headers['layout'].to_sym : nil
  end

  def show_upsell?
    @headers.has_key?('show_upsell') && @headers['show_upsell'].to_s == 'true'
  end

  def show_upsell_header?
    @headers.has_key?('show_upsell_header') ? @headers['show_upsell_header'].to_s == 'true' : true
  end

  def show_byline?
    is_blog_post?
  end

  def show_upsell_form?
    @headers.has_key?('show_upsell_form') && @headers['show_upsell_form'] == 'true'
  end

  def pdf_template
    @headers.has_key?('pdf_template') ? @headers['pdf_template'].to_sym : :pdf
  end

  def docverter_markdown
"""% #{@headers['title']}
%
% #{natural_date}

#{@body}
"""
  end

  def markdown_content
"""# #{title}

#{natural_date}

#{body}

URL: http://pkn.me/#{page_id}
"""
  end

end
