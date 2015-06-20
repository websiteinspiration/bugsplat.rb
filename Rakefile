# -*-ruby-*-

require 'rake'
require 'digest/sha1'
require 'set'
require 'sinatra/asset_pipeline/task.rb'
require 'asset_sync'
require 'dotenv/tasks'

$:.unshift(File.dirname(__FILE__))
require 'app'

Sinatra::AssetPipeline::Task.define! App

task :next do
  print "Title: "
  title = $stdin.gets.chomp

  now = Time.now
  slug_name = title.gsub(/\s+/, '-').gsub("'", '').gsub(/[()]/, '').gsub(':', '').downcase
  slug = "#{now.strftime('%Y-%m-%d')}-#{slug_name}"
  id = Digest::SHA1.hexdigest(slug)[0,5]

  filename = "entries/#{slug}.md"
  contents = <<HERE
---
title: #{title}
id:    #{id}
tags:  
---

HERE

  open(filename, "w+") do |f|
    f.write(contents)
  end

  Kernel.exec(ENV['EDITOR'], '-n', '+6', filename)
  
end

task :server do
  sh "bundle exec shotgun -I."
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
  task :precompile => [:dotenv, :write_nginx_file] do

    Dotenv.load("#{ENV['HOME']}/.pkdc")
    Dotenv.load('.env')

    dirname = File.dirname(__FILE__)
    FileUtils.mkdir_p(File.join(dirname, "public", "stylesheets"))
    FileUtils.mkdir_p(File.join(dirname, "public", "javascripts"))

    STDERR.puts "Compiling pages"
    app = App.new
    request = Rack::MockRequest.new(app)

    dirname = File.dirname(__FILE__)
    FileUtils.mkdir_p(File.join(dirname, "public", "stylesheets"))
    FileUtils.mkdir_p(File.join(dirname, "public", "javascripts"))

    tags = {}
    topics = {}

    App::PAGES.each do |page|
      page.tags.each do |tag|
        tags[tag] = true
      end

      topics[page.topic] = true

      write_page("#{page.name}.html", request)
      write_page("#{page.name}.pdf", request)
      write_page("#{page.name}.md", request)
    end

    ['sitemap.xml', 'index.xml', 'index.html', 'tags.html', 'articles.html', 'archive.html', 'mastering-modern-payments.html'].each do |page|
      write_page(page, request)
    end

    tags.keys.each do |tag|
      write_page("/tag/#{tag}.html", request)
    end

    topics.keys.each do |tag|
      write_page("/tag/#{tag}.html", request)
    end

    AssetSync.configure do |config|
      config.fog_provider = 'AWS'
      config.fog_directory = ENV['FOG_DIRECTORY']
      config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
      config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
      config.prefix = 'assets'
      config.public_path = Pathname('./public')
      config.log_silently = false
    end

    AssetSync.sync
  end
end

task :write_nginx_file => :dotenv do
  Dotenv.load('.env')
  File.open(".nginx", "w+") do |f|
    pages = App::PAGES
    f.write ERB.new(File.read('.nginx.erb')).result(binding)
  end
end


def write_page(path, request)
  STDERR.puts path
  filename = File.join(File.dirname(__FILE__), "public", path)
  FileUtils.mkdir_p(File.dirname(filename))

  contents = request.get(URI.escape(path)).body.force_encoding('utf-8')

  File.open(filename, "w+") do |f|
    f.write(contents)
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

task :convert_to_yaml do
  pages = App::PAGES
  pages.each do |page|
    headers = YAML.dump(page.headers)

    File.open("entries/" + page.original_filename, 'w+') do |file|
      file.write(headers)
      file.write("---\n\n")
      file.write(page.original_body)
    end
  end
end

task :topicless do
  pages = App::PAGES
  topicless = []
  pages.each do |page|
    topicless << page if page.topic.nil?
  end

  topicless.each do |page|
    puts "entries/" + page.original_filename
  end
end
