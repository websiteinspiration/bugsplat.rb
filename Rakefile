# -*-ruby-*-

require 'rake'
require 'digest/sha1'
require 'set'
require 'gibbon'
require 'anemone'

$:.unshift(File.dirname(__FILE__))
require 'app'

task :next do
  print "Title: "
  title = $stdin.gets.chomp

  now = Time.now
  slug_name = title.gsub(/\s+/, '-').gsub("'", '').gsub(/[()]/, '').gsub(':', '').downcase
  slug = "#{now.strftime('%Y-%m-%d')}-#{slug_name}"
  id = Digest::SHA1.hexdigest(slug)[0,5]

  filename = "entries/#{slug}.md"
  contents = <<HERE
Title: #{title}
Id:    #{id}
Tags:  

HERE

  open(filename, "w+") do |f|
    f.write(contents)
  end

  Kernel.exec(ENV['EDITOR'], '-n', '+6', filename)
  
end

task :server do
  sh "bundle exec shotgun -I."
end

task :spider do
  Anemone.crawl("http://www.petekeen.com") do |a|
    a.skip_links_like(/(pdf|docx)/)
    a.on_every_page do |p|
      puts p.url if p.code == 404
    end
  end
end

task :deploy do
  sh "git push origin master"
  sh "cap deploy"
  Rake::Task["spider"].invoke
end

task :tags do
  tags = Set.new
  Dir.glob(File.join(File.dirname(__FILE__), "entries", "*.md")).map do |fullpath|
    File.open(fullpath) do |f|
      headers, body = f.read.split(/\n\n/, 2)
      headers.split("\n").each do |header|
        name, value = header.split(/:\s+/, 2)
        if name == 'Tags'
          value.split(/,\s+/).each do |t|
            tags.add t
          end
        end
      end
    end
  end

  tags.sort.each { |t| puts t }
end

task :tagless do
  App::PAGES.each do |page|
    next unless page.is_blog_post?
    next if page.tags.length > 0
    puts "entries/#{page.name}.md"
  end
end

namespace :assets do
  task :precompile do

    if File.exists?('.asset_host')
      ENV['ASSET_HOST'] = File.read('.asset_host')
    end

    puts "Compiling pages"
    app = App.new
    request = Rack::MockRequest.new(app)

    dirname = File.dirname(__FILE__)
    FileUtils.mkdir_p(File.join(dirname, "public", "stylesheets"))
    FileUtils.mkdir_p(File.join(dirname, "public", "javascripts"))

    tags = {}

    App::PAGES.each do |page|
      page.tags.each do |tag|
        tags[tag] = true
      end

      write_page("#{page.name}.html", request)
    end

    ['sitemap.xml', 'index.xml', 'index.html', 'tags.html', 'archive.html'].each do |page|
      write_page(page, request)
    end

    tags.keys.each do |tag|
      write_page("/tag/#{tag}.html", request)
    end

    App.assets.precompile
    
  end
end

def write_page(path, request)
  puts path
  filename = File.join(File.dirname(__FILE__), "public", path)
  FileUtils.mkdir_p(File.dirname(filename))

  contents = request.get(URI.escape(path)).body.force_encoding('utf-8')

  File.open(filename, "w+") do |f|
    f.write(contents)
  end
end


namespace :email do
  task :send do
    gibbon = Gibbon.new
    list_id = gibbon.lists(:filters => {:list_name => 'Bugsplat Blog Posts'})['data'][0]['id']
    template_id = gibbon.templates['user'][0]['id']
    campaigns = gibbon.campaigns(:limit => 1000)['data']
    campaign_titles = campaigns.map { |c| c['title'] }

    App::PAGES.blog_posts.each do |post|
      title = "bugsplat-#{post['id']}"
      next if campaign_titles.include? title

      puts "Creating campaign for '#{post.title}'"

      campaign_id = gibbon.campaign_create(
        :type => :regular,
        :content => {
          :html_std_content00 => "<h1><a href=\"https://bugsplat.info/#{post.html_path}\">#{post.title}</a></h1>" + post.render,
          :text => "##{post.title}\n\n" + post.body + "\n\nhttps://bugsplat.info/#{post.html_path}",
        },
        :options => {
          :list_id     => list_id,
          :subject     => "New blog post on bugsplat.info: #{post.title}",
          :from_email  => 'pete@bugsplat.info',
          :from_name   => 'Pete Keen',
          :template_id => template_id,
          :title       => title,
        }
      )

      gibbon.campaign_send_now(:cid => campaign_id)
    end
  end

  task :delete_all do
    gibbon = Gibbon.new

    campaigns = []
    begin
      campaigns = gibbon.campaigns(:limit => 1000)['data']
      campaigns.each do |c|
        puts "deleting #{c['title']}"
        gibbon.campaign_delete :cid => c['id']
      end
    end while campaigns.length > 0
  end
end

task :count do
  code_count = 0
  word_count = 0
  
  Dir.glob('entries/*.md').sort.each do |file|

    file_code_count = 0
    file_word_count = 0

    in_backtick_code_block = false
    in_space_code_block = false
    File.open(file).each do |line|

      next if line =~ /^\w+:/
      next if line =~ /\[[\w\s _]+\]:/
      
      if line =~ /^```/
        in_backtick_code_block = !in_backtick_code_block
        next
      end

      if line =~ /^    /
        in_space_code_block = true
      end

      if line !~ /^    / && in_space_code_block
        in_space_code_block = false
      end

      if in_backtick_code_block || in_space_code_block
        file_code_count += 1 unless line =~ /^\s+$/
      else
        file_word_count += line.split(/\s+/).compact.size
      end
    end

    code_count += file_code_count
    word_count += file_word_count

    puts "#{file}: #{file_word_count} #{file_code_count}"
  end

  puts "overall: #{word_count} #{code_count}"
end
