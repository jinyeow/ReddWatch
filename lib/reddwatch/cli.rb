require 'reddwatch'

module Reddwatch
  class CLI
    def self.execute(options={})
      new(options).run
    end

    def initialize(options={})
      @options = options

      # @notifier = Reddwatch::Notifier::LibNotify.new

      # @watching = @options[:watch] || Reddwatch::DEFAULT_WATCH_LIST
      # @processor = Reddwatch::Processor.const_get(DEFAULT_PROCESSOR)
      #   .new({list: @watching})
    end

    def run
      start if @options[:start]
      stop if @options[:stop]
      status if @options[:status]
    end

    def start
      write_cmd('START')
    end

    def stop
      write_cmd('STOP')
    end

    def status
      write_cmd('STATUS')
    end

    private
      
      def write_cmd(cmd)
        File.open(FIFO_FILE, 'w') { |f| f.write "#{cmd}" }
      end
  end
end
