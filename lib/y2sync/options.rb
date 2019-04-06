require "singleton"
require "optparse"

module Y2sync
  class Options
    include Singleton

    attr_reader :verbose, :branch, :command, :require
    attr_writer :command

    def initialize
      OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options] [command]"

        opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
          self.verbose = v
        end

        opts.on("-r", "--require", "Require a file") do |r|
          self.require = r
        end

        opts.on("-b", "--branch", "Branch to checkout (default \"master\")") do |b|
          self.branch = b
        end
      end.parse!

      self.command = ARGV.shift
      self.branch = "master" unless branch
    end

  private

    attr_writer :verbose, :branch, :require
  end
end
