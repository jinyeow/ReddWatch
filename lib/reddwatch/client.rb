require 'reddwatch'

module Reddwatch
  class Client
    def self.execute(options={})
      new(options).run
    end

    def initialize(options={})
      @options = options

      @fifo     = Reddwatch::FIFO.new
      @logger   = Reddwatch::Logger
      @notifier = Reddwatch::Notifier::LibNotify.new
    end

    def run
      %w(start stop status subscribe list unsubscribe clear llist create watch delete restart print).each do |s|
        if @options[s.to_sym] then
          @logger.log("EVENT: in client##{s}.")
          send(s)
        end
      end
    end

    def start
      write_fifo('START')
    end

    def stop
      write_fifo('STOP')
    end

    def status
      write_fifo('STATUS')
    end

    def subscribe
      write_fifo("SUBSCRIBE #{@options[:subscribe].join(',')}")
    end

    def list
      # write_fifo('LIST')
      results = wait_fifo_reply_and_lock('LIST').gsub(',', "\n")
      puts "#{results}"
    end

    def unsubscribe
      write_fifo("UNSUBSCRIBE #{@options[:unsubscribe].join(',')}")
    end

    def clear
      write_fifo('CLEAR')
    end

    def llist
      # write_fifo('LLIST')
      results = wait_fifo_reply_and_lock('LLIST').gsub(',', "\n")
      puts "#{results}"
    end

    def create
      write_fifo("CREATE #{@options[:create]}")
    end

    def watch
      write_fifo("WATCH #{@options[:watch]}")
    end

    def delete
      write_fifo("DELETE #{@options[:delete]}")
    end

    def restart
      write_fifo('RESTART')
    end

    def print
      # write_fifo('PRINT')
      results = wait_fifo_reply_and_lock('PRINT')
      puts results
    end

    private
      
      def write_fifo(cmd)
        @fifo.write(cmd)
      end

      def read_fifo
        @fifo.read.strip
      end

      def fifo_locked?
        @fifo.locked?
      end

      def lock_fifo
        @fifo.lock
      end

      def unlock_fifo
        @fifo.unlock
      end

      def wait_fifo_reply_and_lock(cmd)
        loop { break if @fifo.sync }
        write_fifo(cmd)
        lock_fifo
        sleep 0.5 while fifo_locked?
        results = read_fifo
        lock_fifo
        @fifo.desync
        return "#{results}"
      end
  end
end
