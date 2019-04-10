require "rainbow"

module Y2sync
  # Print the results summary
  class Results
    attr_reader :results

    def initialize(results)
      @results = results
    end

    def print
      success
      errors
    end

  private

    def success
      n = results.count(&:success)
      puts Rainbow("Synchronized #{n} repositories").green
    end

    def errors
      n = results.count { |r| !r.success }
      return if n == 0

      puts Rainbow("Found #{n} errors\n\n").red
      results.each do |r|
        puts Rainbow("ERROR: #{r.error_msg}").red
      end
    end
  end
end
