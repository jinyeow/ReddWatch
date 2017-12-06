require 'reddwatch'

module Reddwatch
  class CLI
    def self.execute(options={})
      new(options).run
    end

    def initialize(options={})
      @options = options

      @watching = @options[:watch] || Reddwatch::DEFAULT_WATCH_LIST

      # if !@watching.exists? then warn("[fail] Can't find list: #{@watching}")

      @processor = Reddwatch::DEFAULT_CLI_PROCESSOR
    end

    # TODO
    def run
      start if @options[:start]
      stop if @options[:stop]

      status if @options[:status]
    end

    # Start cron
    def start
      Reddwatch.daemonize
      Reddwatch::Processor.const_get(@processor).run(@watching)
    end

    # Stop cron
    def stop
      Reddwatch::Processor.const_get(@processor).stop
    end

    # Print running/not running
    def status
      Reddwatch::Processor.const_get(@processor).status
    end
  end
end
