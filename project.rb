require 'rugged'
require 'yaml'

class Project
  def initialize(path)
    @path = path
    @repo = Rugged::Repository.new(@path)
    load_config
  end

  def load_config
    data = repo_data(".repo.yml")
    @config = data.nil? ? {} : YAML.load(data)
  end

  def name
    @config['name'] || base_path.gsub('.git', '')
  end

  def description
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

  def repo_data(path, refspec='refs/heads/master')
    ref = @repo.ref(refspec)
    blob = @repo.blob_at(ref.target, path)
    if blob
      blob.read_raw.data.encode('UTF-8')
    else
      nil
    end
  end

  def readme_contents
    repo_data("README.md") || ""
  end

  def cache_key
    rev = @repo.head.commit.id
    "#{@path}-#{rev}"
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
