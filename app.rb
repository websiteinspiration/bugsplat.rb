#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra/base'
require 'page'
require 'strip_renderer'
require 'atom/pub'
require 'docverter'
require 'sinatra/asset_pipeline'
require 'xml-sitemap'
require 'split'
require 'sinatra/cookies'
require 'gibbon'
require './cookie_adapter'
require 'pony'

class App < Sinatra::Base


  Split.configure do |config|
    config.persistence = CookieAdapter
  end

  PAGES = Pages.new

  Docverter.base_url = 'http://c.docverter.com'

  set :assets_precompile, %w(application.js gz_test.js application.css print.css *.png *.jpg *.svg *.eot *.ttf *.woff *.ico)
  set :assets_css_compressor, :yui
  set :assets_js_compressor, :uglifier
  set :assets_host, 'drgn15pdxue9y.cloudfront.net'
  set :assets_protocol, :https

  register Sinatra::AssetPipeline


  helpers Sinatra::Cookies
  helpers Split::Helper
  helpers do

    def title(with_suffix=true)
      _title = if @page
        @page['title']
      elsif @page_title
        @page_title
      else
        nil
      end

      if with_suffix && (@page.nil? || @page['skip_title_suffix'].nil?)
        _title = [_title, "Pete Keen"].compact.join(" | ")
      end
      _title
    end

    def page_url
      path = request.fullpath.
        gsub("index.html", '').
        gsub(".html", '')
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

    def external_link_tag(text, url)
      "<a href=\"#{url}\" target=\"_blank\">#{text} <i class=\"small fa fa-external-link\"></i></a>"
    end

    def partial(name, locals={})
      render :erb, name, layout: false, locals: locals
    end
  end

  before do
    @pages = PAGES
  end

  get '/' do
    @index_pages = @pages.blog_posts.sort_by(&:date).reverse[0,4]
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
    @archive_pages = @pages.blog_posts.sort_by(&:date).reverse
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

  get '/cheat' do
    redirect '/stripe-webhook-event-cheatsheet'
  end

  get %r{^/stripe-webhook-event-cheatsheet(\.html)?$} do
    @title = @page_title = 'The Stripe Webhook Event Cheatsheet'
    @full_path = '/stripe-webhook-event-cheatsheet'
    @description = "Fourteen common scenarios and the hooks that Stripe fires for them, including full JSON samples."
    @skip_masthead = true
    @body_class = "book"
    @post_url = 'http://pkn.me/cheat'
    erb :stripe_event_cheatsheet
  end

  get '/list' do
    redirect '/the-big-list-of-stripe-resources'
  end

  get %r{^/the-big-list-of-stripe-resources(\.html)?$} do
    @title = @page_title = 'The Big List of Stripe Resources'
    @full_path = '/the-big-list-of-stripe-resources'
    @description = "Links to the best Stripe code and learning resources."
    @post_url = 'http://pkn.me/list'
    erb :resources
  end

  get '/tag/:tag' do
    tag = params[:tag].gsub('.html', '').downcase
    @tagged_pages = @pages.tagged(tag).sort_by(&:date).reverse
    @tag_name = params[:tag].gsub('.html', '')
    @page_title = "Tagged " + @tag_name
    erb :tagged_pages
  end

  get %r{^/([\w-]+)(\.)?(\w+)?$} do
    params[:page_name] = params[:captures].first
    params[:format] = params[:captures].last
    @hide_discussion = true

    @page = @pages.find(params[:page_name])

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

    if @page['thumbnail']
      @thumbnail = @page['thumbnail']
    end

    if params[:format] == 'md'
      content_type "text/plain"
      return @page.markdown_content
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
      c.content  = erb(@page.pdf_template, layout: false).gsub('&#39;', "'")

      Dir.glob(File.join(public_path, "fonts", "*.ttf")).each do |font|
        c.add_other_file font
      end
    end

    content_type 'application/pdf'
    res
  end

  post '/subscribe' do
    email = params[:email]
    gb = Gibbon::API.new
    begin
      gb.lists.subscribe({
        id:           params[:list_id] || ENV['MAILCHIMP_LIST_ID'],
        email:        {:email => email},
        double_optin: false
      })
    rescue StandardError => e
      return e.message
    end
    redirect params[:next]
  end

  post '/checkup-apply-form' do
    text = params.map do |key, val|
      "#{key}:\n\n#{val}\n\n"
    end.join("\n")
    sendmail(
      to: 'pete@petekeen.net',
      from: params[:email],
      subject: "Stripe Checkup application",
      body: text
    )
    redirect '/checkup-apply-done'
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

  def sendmail(options)
    options.merge!(
      via: :smtp,
      via_options: {
        address:   ENV['SMTP_SERVER_ADDRESS'],
        port:      ENV['SMTP_SERVER_PORT'],
        user_name: ENV['SMTP_SERVER_USERNAME'],
        password:  ENV['SMTP_SERVER_PASSWORD'],
        domain:    ENV['SMTP_SERVER_DOMAIN'],
        enable_starttls_auto: true,
        authenticaton: :login
      }
    )
    Pony.mail(options)
  end
end

