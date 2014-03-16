require 'grit'
require 'yaml'

class Project
  def initialize(path)
    @path = path
    load_config
    @config = YAML.load(repo_data(".repo.yml"))
  end

  def load_config
    data = repo_data(".repo.yml")
    @config = data.nil? ? {} : YAML.load(data)
  end

  def description
    @config['name'] || base_path.gsub('.git', '')
  end

  def name
    @config['description'] || "No description"
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

  def repo_data(path)
    repo = Grit::Repo.new(@path)
    obj = repo.tree / path
    if obj
      obj.data.encode('UTF-8')
    else
      nil
    end
  end

  def readme_contents
    repo_data("README.md") || ""
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
