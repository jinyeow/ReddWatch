require 'reddwatch'

module Reddwatch
  class CLI
    def self.execute(options={})
      new(options).run
    end

    def initialize(options={})
      @options = options

      @notifier = Reddwatch::Notifier::LibNotify.new
      @logger   = Reddwatch::Logger

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
      @logger.log('EVENT: in cli#subscribe.')
      write_fifo("SUBSCRIBE #{@options[:subscribe].join(',')}")
    end

    def list
      # TODO: choose a method to reply to the client
      #       either a 2-way fifo/pipe
      #       or 2 different fifos/pipes
      #       or move clear_fifo to each case as needed.
      @logger.log('EVENT: in cli#list.')
      write_fifo("LIST") and mtime = File.mtime(FIFO_FILE)
      puts "#{read_fifo}" if File.mtime(FIFO_FILE) > mtime
    end

    def unsubscribe
      @logger.log('EVENT: in cli#unsubscribe.')
      write_fifo("UNSUBSCRIBE #{@options[:unsubscribe].join(',')}")
    end

    private
      
      def write_fifo(cmd)
        File.open(FIFO_FILE, 'w') { |f| f.write "#{cmd}" }
      end

      def read_fifo
        File.open(FIFO_FILE, 'r').readline.strip
      end
  end
end
