#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra/base'
require 'page'
require 'atom/pub'
require 'docverter'
require 'sinatra/simple_assets'

class App < Sinatra::Base

  RENDERER = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :fenced_code_blocks => true)
  PAGES = Page.parse_all(RENDERER)
  PAGE_CACHE = {}

  Docverter.api_key = ENV['DOCVERTER_API_KEY']

  register Sinatra::SimpleAssets
  assets do
    css :application, [
      '/main.css',
      '/page.css',
      '/table.css',
      '/github.css'
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
      else
        return "bugsplat"
      end
    end

    def link_list
      linked_pages = @pages.find_all { |p| p['order'] != nil }
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
      @index_pages = @pages.find_all { |p| p.is_blog_post? }.sort_by { |p| p.date }.reverse[0,5]
      erb :index
    end
  end

  get '/index.html' do
    @index_pages = @pages.find_all { |p| p.is_blog_post? }.sort_by { |p| p.date }.reverse[0,5]
    erb :index
  end

  get '/index.xml' do
    @archive_pages = @pages.find_all { |p| p.is_blog_post? }.sort_by { |p| p.date }.reverse
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
    @archive_pages = @pages.find_all { |p| p.is_blog_post? }.sort_by { |p| p.date }.reverse
    erb :archive
  end

  get '/tags.html' do
    tags = {}
    @pages.each do |page|
      page.tags.each do |tag|
        tags[tag] = true
      end
    end
    @tags = tags.keys.sort
    erb :tags
  end

  get '/tag/:tag.html' do
    @tagged_pages = @pages.find_all { |p| p.has_tag params[:tag] }.sort_by{ |p| p.date }.reverse
    @tag_name = params[:tag]
    erb :tagged_pages
  end

  get '/:page_name.:format' do
    @hide_discussion = true
    @page = @pages.detect { |p| p.matches_path(params[:page_name]) }
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
end

