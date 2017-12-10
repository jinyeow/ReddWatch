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

      # @watching = @options[:watch] || Reddwatch::DEFAULT_WATCH_LIST
      # @processor = Reddwatch::Processor.const_get(DEFAULT_PROCESSOR)
      #   .new({list: @watching})
    end

    def run
      start if @options[:start]
      stop if @options[:stop]
      status if @options[:status]
      subscribe if @options[:subscribe]
      list if @options[:list]
      unsubscribe if @options[:unsubscribe]
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
      @logger.log('EVENT: in client#subscribe.')
      write_fifo("SUBSCRIBE #{@options[:subscribe].join(',')}")
    end

    def list
      @logger.log('EVENT: in client#list.')
      write_fifo("LIST")
      lock_fifo
      sleep 0.5 while fifo_locked?
      results = read_fifo.gsub(',', "\n")
      puts "#{results}"
      lock_fifo
    end

    def unsubscribe
      @logger.log('EVENT: in client#unsubscribe.')
      write_fifo("UNSUBSCRIBE #{@options[:unsubscribe].join(',')}")
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
