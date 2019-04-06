
require "octokit"
require "parallel"
require "shellwords"
require "English"

module Y2sync
  class Repo
    TARGET_BRANCH = "master".freeze

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
      client.list_repositories("yast").map { |r| Repo.new(r) }
    end

    def self.branch(branch)
      all.reject { |r| IGNORED_REPOS[branch].include?(r.name) }
    end

    def self.sync_all(repos)
      # TODO limit the initial cloning to 4 processes?
      Parallel.map(repos, progress: "Synchronizing...", &:sync)
    end

    # octokit info
    attr_reader :repo

    def initialize(info)
      @repo = info
    end

    def dir
      # remove the "yast-" prefix, make searching in the directory easier
      repo.name.gsub(/^yast-/, "")
    end

    def target_dir
      File.join(Y2sync::Options.instance.dir, dir)
    end

    def clone_repo
      # FIXME: read the stderr
      cmd = "git clone --quiet --branch #{Shellwords.escape(TARGET_BRANCH)} " \
      "#{Shellwords.escape(repo.git_url)} #{Shellwords.escape(target_dir)}"

      `#{cmd}`

      # FIXME: collect errors?
      SyncResult.new(success: $CHILD_STATUS.success?, empty_repo: true)
    end

    def update_repo
      # stash - make sure any unsubmitted work is not lost by accident
      # reset - ensure consistent state
      # prune - remove the branches which were deleted on the server
      # checkout - ensure the requested branch is set
      # pull - update from origin with rebase
      # TODO: optionally gc
      cmd = "cd #{Shellwords.escape(target_dir)} && git stash save && git reset --hard && git fetch --prune && " \
        "git checkout -q #{Shellwords.escape(TARGET_BRANCH)} && git pull --rebase"

      `#{cmd}`

      return SyncResult.new(success: $CHILD_STATUS.success?, empty_repo: live?)
    end

    def sync
      # clone or update the existing checkout
      if File.exist?(target_dir)
        update_repo
      else
        clone_repo
      end
    end

  private

    def files
      # remove the self and parent directory entries
      Dir.entries(target_dir) - [".", ".."]
    end

    # the dead repositories only contain README.md file
    def live?
      files.size > 1
    end
  end
end
