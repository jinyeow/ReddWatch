require 'reddwatch'

module Reddwatch
  class FIFO
    LOCK_FILE = '/tmp/reddwatch-fifo.locked'

    def initialize(options={})
      @options = options

      @fifo = options[:name] || '/tmp/reddwatch.fifo'
      system("mkfifo #{@fifo}") unless File.exists? @fifo

      @output = open(@fifo, 'w+')
      @input  = open(@fifo, 'r+')
    end

    def write(msg)
      @output.puts(msg)
      @output.flush
    end

    def read
      @input.gets
    end

    def clear
      write('')
    end

    def name
      @fifo
    end

    def close
      File.delete @fifo
    end

    def lock
      File.open(LOCK_FILE, 'w') {} unless locked?
    end

    def unlock
      File.delete(LOCK_FILE) if locked?
    end

    def locked?
      File.exists? LOCK_FILE
    end
  end
end
