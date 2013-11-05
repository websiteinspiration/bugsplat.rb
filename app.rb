#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra/base'
require 'page'
require 'strip_renderer'
require 'atom/pub'
require 'docverter'
require 'sinatra/simple_assets'
require 'xml-sitemap'
require 'split'
require 'sinatra/cookies'
require './cookie_adapter'

class App < Sinatra::Base

  Split.configure do |config|
    config.persistence = CookieAdapter
  end

  PAGES = Pages.new

  Docverter.base_url = 'http://c.docverter.com'

  register Sinatra::SimpleAssets
  assets do
    css :application, [
      '/css/bootstrap.css',
      '/css/main.css',
      '/css/github.css',
      '/css/font-awesome.css',
      '/css/colorbox.css'
    ]

    css :ie7, [
      '/css/font-awesome-ie7.css'
    ]

    css :print, [
      '/css/print.css'
    ]

    js :application, [
      '/js/jquery.js',
      '/js/purl.js',
      '/js/bootstrap.js',
      '/js/jquery.cookie.js',
      '/js/jquery.colorbox.js',
      '/js/book.js'
    ]
  end

  def url_for_asset(file)
    url = file[0] == '/' ? file : "/#{file}"
    ENV['ASSET_HOST'] ? "#{ENV['ASSET_HOST']}#{url}" : url
  end

  helpers Sinatra::Cookies
  helpers Split::Helper
  helpers do

    def relative_stylesheet(bundle, media="screen")
      settings.assets.paths_for("#{bundle}.css").map do |file|
        "<link media=\"#{media}\" rel=\"stylesheet\" href=\"#{url_for_asset(file)}\">"
      end.join("\n")
    end

    def relative_javascript(bundle, async=false)
      settings.assets.paths_for("#{bundle}.js").map do |file|
        async_val = async ? "async" : ""
        "<script src=\"#{url_for_asset(file)}\" #{async_val}></script>"
      end.join("\n")
    end

    def title
      _title = if @page
        @page['title']
      elsif @page_title
        @page_title
      else
        nil
      end
      unless @page && @page['skip_title_suffix']
        _title = [_title, "Pete Keen"].compact.join(" | ")
      end
      _title
    end

    def page_url
      path = request.fullpath.
        gsub("index.html", '').
        gsub!(".html", '')
      "https://www.petekeen.net" + path
    end

    def link_list
      linked_pages = @pages.pages.find_all { |p| p['order'] != nil }
      links = linked_pages.sort_by { |p| p['order'].to_i }.map do |p|
        "<li><a href=\"/#{p.name}.html\">#{p['title']}</a></li>"
      end
      links.join("\n")
    end

    def has_related_posts(page)
      related_posts(page).length > 0
    end

    def related_posts(page)
      PAGES.related_posts(page)[0..2].compact
    end

    def sales_host
      ENV['SALES_HOST']
    end

    def production?
      ENV['RACK_ENV'] == 'production'
    end

    def showing_mmp?
      @mmp
    end
  end

  before do
    @pages = PAGES
  end

  get '/' do
    @index_pages = @pages.blog_posts.reverse[0,4]
    @description = "My name is Pete Keen. I'm a Ruby developer and in my spare time I write books."
    erb :index
  end

  get '/sitemap.xml' do
    map = XmlSitemap::Map.new('www.petekeen.net') do |m|
      @pages.pages.each do |page|
        m.add page.html_path, :period => :daily
      end
    end
    map.render
  end

  get '/index.html' do
    @index_pages = @pages.blog_posts.reverse[0,5]
    @description = "My name is Pete Keen. I'm a Ruby developer and in my spare time I write books."
    erb :index
  end

  get '/index.xml' do
    @archive_pages = @pages.blog_posts.reverse
    feed = Atom::Feed.new do |f|
      f.title = 'Pete Keen'
      f.links << Atom::Link.new(:href => 'http://www.petekeen.net')
      f.updated = @archive_pages[0].date.to_time
      f.authors << Atom::Person.new(:name => 'Pete Keen', :email => 'pete@bugsplat.info')
  
      @archive_pages.each do |p|
        f.entries << Atom::Entry.new do |e|
          e.title = p['title']
          e.links << Atom::Link.new(:href => "http://www.petekeen.net#{ p.html_path }")
          e.id = p['id']
          e.updated = p.date.to_time
          e.content = Atom::Content::Html.new(p.render)
        end
      end
    end
  
    feed.to_xml
  end

  get %r{^/archive(\.html)?$} do
    @archive_pages = @pages.blog_posts.reverse
    @page_title = "Archive"
    erb :archive
  end

  get %r{^/tags(\.html)?$} do
    tags = {}
    @pages.pages.each do |page|
      page.tags.each do |tag|
        tags[tag] = true
      end
    end
    @tags = tags.keys.sort
    @page_title = "All Tags"
    erb :tags
  end

  get '/mmp' do
    redirect '/mastering-modern-payments'
  end

  get '/mmppo' do
    redirect '/mastering-modern-payments'
  end

  get %r{^/mastering-modern-payments(\.html)?$} do
    @mmp = true
    @page_title = 'Mastering Modern Payments: Using Stripe with Rails by Pete Keen'
    erb :mastering_modern_payments, layout: :book_layout
  end

  get '/mmp-preorders' do
    redirect '/mastering-modern-payments'
  end

  get '/tag/:tag' do
    tag = params[:tag].gsub('.html', '').downcase
    @tagged_pages = @pages.search(tag, "tags").reverse
    @tag_name = params[:tag].gsub('.html', '')
    @page_title = "Tagged " + @tag_name
    erb :tagged_pages
  end

  get %r{^/([\w-]+)(\.)?(\w+)?$} do
    params[:page_name] = params[:captures].first
    params[:format] = params[:captures].last
    @hide_discussion = true

    @page = @pages.search(params[:page_name], "name")[0] || \
            @pages.search(params[:page_name], "page_id")[0] || \
            @pages.pages.detect { |p| p.name == params[:page_name] } || \
            @pages.pages.detect { |p| p.page_id == params[:page_name] }

    unless @page
      raise Sinatra::NotFound
    end

    if @page.page_id == params[:page_name]
      redirect @page.html_path
    end

    params[:format] ||= 'html'

    formats = ['html', 'pdf', 'md']

    unless formats.include?(params[:format])
      raise Sinatra::NotFound
    end

    if @page['description']
      @description = @page['description']
    end

    if params[:format] == 'md'
      content_type "text/plain"
      return @page.contents
    end

    view = @page.view || :entry_page
    layout = @page.layout || :layout

    if params[:format] == 'html'
     return erb view, layout: layout
    end

    public_path = File.expand_path(File.join(__FILE__, "..", "public"))
    res = Docverter::Conversion.run do |c|
      c.from     = 'html'
      c.to       = 'pdf'
      c.content  = erb(:pdf, layout: false).gsub('&#39;', "'")

      Dir.glob(File.join(public_path, "fonts", "*.ttf")).each do |font|
        c.add_other_file font
      end
    end

    content_type 'application/pdf'
    res
  end

  post '/ping' do
    'pong'
  end

  not_found do
    @page_title = "Page Not Found"
    erb :error_404
  end

  error do
    @page_title = "Error"
    erb :error_500
  end
end

