require "singleton"
require "optparse"

module Y2sync
  # Parse command line options
  class Options
    include Singleton

    attr_reader :verbose, :branch, :dir, :command, :require, :debug, :org
    attr_writer :command

    def initialize
      # set the defaults
      self.branch = "master"
      self.dir = Dir.pwd
      self.debug = false
      self.org = "yast"

      OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options] [command]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          self.verbose = v
        end

        opts.on("-r", "--require=FILE", "Require a file") do |r|
          self.require = r
        end

        opts.on("-b", "--branch=BRANCH", "Branch to checkout (default \"master\")") do |b|
          self.branch = b
        end

        opts.on("-d", "--dir=DIR", "Output directory (default: the current directory)") do |d|
          self.dir = d
        end

        opts.on("-g", "--[no-]debug", "Turn on the debug output (default: off)") do |g|
          self.debug = g
        end

        opts.on("-o", "--organization=ORG", "Use this GitHub organization (default: yast)") do |o|
          self.org = o
        end
      end.parse!

      self.command = ARGV.shift
    end

  private

    attr_writer :verbose, :branch, :dir, :require, :debug, :org
  end
end
