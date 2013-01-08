# -*-ruby-*-

require 'rake'
require 'digest/sha1'
require 'set'

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
Date:  #{now.strftime('%Y-%m-%d %H:%M:%S')}
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

namespace :assets do
  task :precompile do

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
