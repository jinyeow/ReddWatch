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
      %w(start stop status subscribe list unsubscribe clear llist create watch delete restart).each do |s|
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
      write_fifo('LIST')
      lock_fifo
      sleep 0.5 while fifo_locked?
      results = read_fifo.gsub(',', "\n")
      puts "#{results}"
      lock_fifo
    end

    def unsubscribe
      write_fifo("UNSUBSCRIBE #{@options[:unsubscribe].join(',')}")
    end

    def clear
      write_fifo('CLEAR')
    end

    def llist
      write_fifo('LLIST')
      lock_fifo
      sleep 0.5 while fifo_locked?
      results = read_fifo.gsub(',', "\n")
      puts "#{results}"
      lock_fifo
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
  end
end
