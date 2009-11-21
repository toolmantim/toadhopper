module ToadHopper
  class BacktraceLine < Struct.new(:file, :number, :method); end

  class Backtrace
    INPUT_FORMAT = %r{^([^:]+):(\d+)(?::in `([^']+)')?$}.freeze
    attr_reader :lines

    def self.from_exception(exception)
      @lines = exception.backtrace.map do |line|
        _, file, number, method = line.match(INPUT_FORMAT).to_a
        BacktraceLine.new(file, number, method)
      end
    end

    def each_line(&block)
      lines.each do |line|
        yield line
      end
    end
  end
end
