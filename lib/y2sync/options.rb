require "singleton"
require "optparse"

module Y2sync
  class Options
    include Singleton

    attr_reader :verbose, :branch, :dir, :command, :require
    attr_writer :command

    def initialize
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
      end.parse!

      self.command = ARGV.shift
      self.branch = "master" unless branch
      self.dir = Dir.pwd unless dir
    end

  private

    attr_writer :verbose, :branch, :dir, :require
  end
end
