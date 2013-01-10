#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra/base'
require 'page'
require 'strip_renderer'
require 'atom/pub'
require 'docverter'
require 'sinatra/simple_assets'
require 'xml-sitemap'

class App < Sinatra::Base

  PAGES = Pages.new
  PAGE_CACHE = {}

  Docverter.base_url = 'http://c.docverter.com'

  register Sinatra::SimpleAssets
  assets do
    css :application, [
      '/main.css',
      '/page.css',
      '/table.css',
      '/github.css',
      '/fontello.css',
    ]

    css :ie7, [
      '/fontello-ie7.css',
    ]

    css :print, [
      '/print.css'
    ]

    js :application, [
      '/jquery.js',
      '/jquery.dataTables.js',
      '/jquery.relatize_date.js',
      '/highlight.pack.js'
    ]
  end

  helpers do

    def relative_stylesheet(bundle, media="screen")
      settings.assets.paths_for("#{bundle}.css").map do |file|
        file = "/#{file}" unless file[0] == '/'
        "<link media=\"#{media}\" rel=\"stylesheet\" href=\"#{file}\">"
      end.join("\n")
    end

    def relative_javascript(bundle, async=false)
      settings.assets.paths_for("#{bundle}.js").map do |file|
        file = "/#{file}" unless file[0] == '/'
        async_val = async ? "async" : ""
        "<script src=\"#{file}\" #{async_val}></script>"
      end.join("\n")
    end

    def title
      if @page
        return "#{@page['title']} | bugsplat"
      elsif @page_title
        return "#{@page_title} | bugsplat"
      else
        return "bugsplat"
      end
    end

    def link_list
      linked_pages = @pages.pages.find_all { |p| p['order'] != nil }
      links = linked_pages.sort_by { |p| p['order'].to_i }.map do |p|
        "<li><a href=\"/#{p.name}.html\">#{p['title']}</a></li>"
      end
      links.join("\n")
    end
  end

  before do
    @pages = PAGES
  end

  get '/' do
    path = File.expand_path(File.join(__FILE__, "..", "public", "index.html"))
    if settings.environment == :production && File.exists?(path)
      send_file path
    else
      @index_pages = @pages.blog_posts.reverse[0,5]
      erb :index
    end
  end

  get '/sitemap.xml' do
    map = XmlSitemap::Map.new('bugsplat.info') do |m|
      @pages.all do |page|
        m.add page.html_path, :period => :daily
      end
    end
    map.render
  end

  get '/index.html' do
    @index_pages = @pages.blog_posts.reverse[0,5]
    erb :index
  end

  get '/index.xml' do
    @archive_pages = @pages.blog_posts.reverse
    feed = Atom::Feed.new do |f|
      f.title = 'Bugsplat'
      f.links << Atom::Link.new(:href => 'http://bugsplat.info')
      f.updated = @archive_pages[0].date.to_time
      f.authors << Atom::Person.new(:name => 'Pete Keen', :email => 'pete@bugsplat.info')
  
      @archive_pages.each do |p|
        f.entries << Atom::Entry.new do |e|
          e.title = p['title']
          e.links << Atom::Link.new(:href => "http://bugsplat.info#{ p.html_path }")
          e.id = p['id']
          e.updated = p.date.to_time
          e.content = Atom::Content::Html.new(p.render)
        end
      end
    end
  
    feed.to_xml
  end

  get '/archive.html' do
    @archive_pages = @pages.blog_posts.reverse
    @page_title = "Archive"
    erb :archive
  end

  get '/tags.html' do
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

  get '/tag/:tag.html' do
    @tagged_pages = @pages.search(params[:tag].downcase, "tags").reverse
    @page_title = @tag_name = params[:tag]
    erb :tagged_pages
  end

  get '/search' do
    @query = (params[:q] || "").strip
    if @query == ""
      @results = []
    else
      query = @query.downcase.gsub(" or ", " OR ")
      @results = @pages.search("(#{query}) blog_post:yes").reverse
    end
    @page_title = "Search"
    erb :search
  end

  get '/:page_name.:format' do
    @hide_discussion = true
    @page = @pages.search(params[:page_name], "name")[0] || @pages.search(params[:page_name], "id")[0]
    unless @page
      raise Sinatra::NotFound
    end

    formats = {
      'pdf' => ['pdf_template.html', 'application/pdf'],
      'docx' => [nil, 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
      'html' => [],
      'md' => [],
    }

    unless formats.include?(params[:format])
      raise Sinatra::NotFound
    end

    if params[:page_name] == @page['id']
      redirect @page.html_path
    end

    if params[:format] == 'html'
      return erb :entry_page
    end

    if params[:format] == 'md'
      content_type "text/plain"
      return @page.contents
    end

    public_path = File.expand_path(File.join(__FILE__, "..", "public"))
    res = Docverter::Conversion.run do |c|
      c.from     = 'markdown'
      c.to       = params[:format]
      if formats[params[:format]][0]
        c.template = formats[params[:format]][0]
      end
      c.content  = @page.docverter_markdown

      c.add_other_file File.join(public_path, "droid_sans.ttf")
      c.add_other_file File.join(public_path, "droid_serif.ttf")
      c.add_other_file File.join(public_path, "..", "pdf_template.html")
    end

    content_type formats[params[:format]][1]
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

