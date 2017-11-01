require 'reddwatch'

module Reddwatch
  class CLI
    def self.execute(options={})
      new(options).run
    end

    def initialize(options={})
      @options = options

      @watching = options[:watch] || Reddwatch::DEFAULT_WATCH_LIST
    end

    # TODO
    def run
    end
  end
end
