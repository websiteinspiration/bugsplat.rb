require 'grit'

class Project
  def initialize(path)
    @path = path
  end

  def description
    File.read(File.join(@path, 'description')) rescue "No Description"
  end

  def name
    File.read(File.join(@path, 'name')) rescue base_path.gsub('.git', '')
  end

  def clone_url
    "https://www.petekeen.net/source/#{base_path}"
  end

  def information_page
    "/projects/#{base_path.gsub('.git', '')}"
  end

  def base_path
    File.basename(@path)
  end

  def readme_contents
    repo = Grit::Repo.new(@path)
    obj = repo.tree / "README.md"
    if obj
      obj.data.encode('UTF-8')
    else
      ""
    end
  end

  def self.all
    Dir[File.join(ENV['PROJECTS_REPOS_ROOT'], "*.git")].sort.map do |dir|
      Project.new(dir)
    end
  end

  def self.find(name)
    path = File.join(ENV['PROJECTS_REPOS_ROOT'], "#{name}.git")
    if File.directory?(path)
      Project.new(path)
    else
      nil
    end
  end
end
