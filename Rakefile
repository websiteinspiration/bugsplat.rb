# -*-ruby-*-

require 'rake'
require 'digest/sha1'

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

HERE

  open(filename, "w+") do |f|
    f.write(contents)
  end

  Kernel.exec(ENV['EDITOR'], '-n', '+5', filename)
  
end
