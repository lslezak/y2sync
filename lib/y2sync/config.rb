require "yaml"

module Y2sync
  class Config
    FILE_NAME = ".y2sync.yml".freeze

    attr_reader :branch, :empty_repos, :file

    def initialize(file: nil, branch: "master", empty_repos: [])
      @file = file
      @branch = branch
      @empty_repos = empty_repos
    end

    def self.read(file = FILE_NAME)
      dir = Dir.pwd
      path = File.join(dir, file)

      while !File.exist?(path) && dir != "/"
        dir = Pathname.new(dir).parent.to_s
        path = File.join(dir, file)
      end

      if File.exist?(path)
        cfg = YAML.load_file(path)
        config = Config.new(file: path, branch: cfg["branch"], empty_repos: cfg["empty_repos"])
        return config
      end

      Config.new
    end

    def write
      cfg = {
        "branch"      => branch,
        "empty_repos" => empty_repos
      }
      puts "Writing #{file || FILE_NAME}"
      File.write(file || FILE_NAME, cfg.to_yaml)
    end
  end
end
