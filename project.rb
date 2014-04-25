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

  def path_name
    base_path.gsub('.git', '')
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

  def raw_repo_data(path, refspec='refs/heads/master')
    ref = @repo.ref(refspec)
    blob = @repo.blob_at(ref.target, path)
    if blob
      blob.read_raw.data
    else
      nil
    end
  end

  def readme_contents
    repo_data("README.md") || ""
  end

  def cache_key
    rev = @repo.head.target
    "#{@path}-#{rev}"
  end

  def tree_list(path, refspec='refs/heads/master')
    list = []

    ref = @repo.ref(refspec)
    tree = tree_at_ref_path(ref, path)

    tree.each_tree do |t|
      commit = last_commit(ref, path, t[:name])
      list << ['dir', t[:name], commit.message.split("\n").first, commit.epoch_time]
    end

    tree.each_blob do |t|
      commit = last_commit(ref, path, t[:name])
      list << ['file', t[:name], commit.message.split("\n").first, commit.epoch_time]
    end

    list
  end

  def last_commit(ref, path, name)
    latest_commit = @repo.lookup(ref.target)
    tree = tree_at_ref_path(ref, path)
    latest_oid = tree.get_entry(name)[:oid]

    walker = Rugged::Walker.new(@repo)
    walker.push(ref.target)
    walker.sorting(Rugged::SORT_TOPO)

    prev_commit = latest_commit

    walker.each do |commit|
      tree = tree_at_ref_path(commit.oid, path)
      obj = tree.nil? ? nil : tree.get_entry(name)

      if obj.nil? || obj[:oid] != latest_oid
        return prev_commit
      end
      prev_commit = commit
    end
    return prev_commit    
  end

  def tree_at_ref_path(ref, path)
    ref = ref.target unless ref.is_a?(String)

    if path == ''
      @repo.lookup(ref).tree
    else
      tree = @repo.lookup(ref).tree
      path.split('/').each do |part|
        begin
          info = tree.path(part)
          tree = @repo.lookup(info[:oid])
        rescue Rugged::TreeError => e
          return nil
        end
      end
      tree
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
