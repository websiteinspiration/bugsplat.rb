# -*-ruby-*-

require 'rake'
require 'digest/sha1'
require 'set'

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
