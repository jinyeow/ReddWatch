require 'reddwatch'

module Reddwatch
  module Processor
    class Base
      def self.run(list)
        @list = self.get_list(list)

        @reddit = Reddwatch::Feed::Reddit.new
        @feed   = @reddit.fetch(@list.join('+'))

        @notifier = Reddwatch::Notifier::LibNotify.new

        # TODO: check time stamps before sending out notifications
        # TODO: use Process.daemon to daemonize Reddwatch
        @feed.each do |post|
          msg = @reddit.create_message(post)
          @notifier.send(msg)
          sleep(5)
        end
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
