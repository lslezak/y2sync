
require "octokit"
require "shellwords"

module Y2sync
  class Repo
    def self.all
      
      # use ~/.netrc ?
      netrc = File.join(Dir.home, ".netrc")
      client_options = if ENV["GH_TOKEN"]
        # Generate at https://github.com/settings/tokens
        { access_token: ENV["GH_TOKEN"] }
      elsif File.exist?(netrc) && File.read(netrc).match(/^machine api.github.com/)
        # see https://github.com/octokit/octokit.rb#authentication
        { netrc: true }
      else
        {}
      end
      
      client = Octokit::Client.new(client_options)
      client.auto_paginate = true

      # TODO: add option for other organizations
      client.list_repositories("yast").map(&:name).sort
    end

    def self.branch(branch)
      all.reject { |r| IGNORED_REPOS[branch].include?(r.name) }
    end

    def self.sync_all(repos)
      Parallel.map(repos, progress: "Progress", &:sync)
    end

    # octokit info
    attr_reader :repo

    def initialize(info)
      @repo = info
    end

    def dir
      # remove the "yast-" prefix, make searching in the directory easier
      repo.name(/^yast-/, "")
    end

    def clone_repo
      cmd = "git clone -b #{Shellwords.escape(TARGET_BRANCH)} " \
        "#{Shellwords.escape(repo.git_url)} #{Shellwords.escape(dir)}"

      `#{cmd}`

      # FIXME: collect errors?
      SyncResult.new(success: $CHILD_STATUS.success?, empty_repo: live?)
    end

    def update_repo
      Dir.cwd(dir) do
        # stash - make sure any unsubmitted work is not lost by accident
        # reset - ensure consistent state
        # prune - remove the branches which were deleted on the server
        # checkout - ensure the requested branch is set
        # pull - update from origin with rebase
        # TODO: optionally gc
        cmd = "git stash save && git reset --hard && git fetch --prune && " \
          "git checkout -q #{Shellwords.escape(TARGET_BRANCH)} && git pull --rebase"
        `#{cmd}`

        return SyncResult.new(success: $CHILD_STATUS.success?, empty_repo: live?)
      end
    end

    def sync
      # clone or update the existing checkout
      if File.exist?(dir)
        update_repo
      else
        clone_repo
      end
    end

  private

    def files
      # remove the self and parent directory entries
      Dir.entries(dir) - [".", ".."]
    end

    # the dead repositories only contain README.md file
    def live?
      files.size > 1
    end
  end
end