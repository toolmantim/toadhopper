module ToadHopper
  # A class to represent a line in a ruby Backtrace
  class BacktraceLine < Struct.new(:file, :number, :method); end

  # A collection of BacktraceLines reprsenting an entire ruby backtrace
  class Backtrace
    INPUT_FORMAT = %r{^([^:]+):(\d+)(?::in `([^']+)')?$}.freeze

    # the collection of lines in the backtrace
    attr_reader :lines

    # create a collection of BacktraceLines from an exception
    def self.from_exception(exception)
      @lines = exception.backtrace.map do |line|
        _, file, number, method = line.match(INPUT_FORMAT).to_a
        BacktraceLine.new(file, number, method)
      end
    end

    # iterate over the lines in a Backtrace
    def each_line(&block) #:nodoc:
      lines.each do |line|
        yield line
      end
    end
  end
end
