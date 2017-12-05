require 'reddwatch'
require 'reddwatch/feed/reddit'

module Reddwatch
  module Processor
    class Base
      def self.run(list)
        @list = self.get_list(list)
      end

      def self.stop
      end

      def self.status
      end

      def self.get_list(list)
        unless File.exists? "#{Reddwatch::DEFAULT_CONFIG_DIR}/#{list}"
          $stderr.puts("ERROR: '#{list}' list does not exist.")
          exit
        end

        open("#{Reddwatch::DEFAULT_CONFIG_DIR}/#{list}", 'r').readlines.map do |line|
          line.strip
        end
      end
    end
  end
end
