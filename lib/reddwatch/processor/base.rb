require 'reddwatch'

module Reddwatch
  module Processor
    class Base
      def self.run(list)
        @list = self.get_list(list)

        @reddit = Reddwatch::Feed::Reddit.new
        @notifier = Reddwatch::Notifier::LibNotify.new

        @feed   = @reddit.fetch(@list.join('+'))

        # TODO: setup a loop
        # TODO: check time stamps before sending out notifications
        @feed.each do |post|
          msg = @reddit.create_message(post)
          @notifier.send(msg)
          sleep(5)
        end
      end

      def self.stop
        if File.exists? '/tmp/reddwatch.pid' then
          pid = open('/tmp/reddwatch.pid', 'r').readline.strip.to_i
          Process.kill("KILL", pid)
          File.delete('/tmp/reddwatch.pid')
        else
          puts "ERROR: ReddWatch is not running."
        end
      end

      def self.status
        msg = {
          title: "#{Reddwatch::APP_NAME} - Status",
          content: 'Stopped.',
          level: 'dialog-info'
        }

        msg[:content] = "Running..." if File.exists? '/tmp/reddwatch.pid'
        
        Reddwatch::Notifier::LibNotify.new.send(msg)
      end

      def self.get_list(list)
        unless File.exists? "#{Reddwatch::DEFAULT_LIST_DIR}/#{list}"
          $stderr.puts("ERROR: '#{list}' list does not exist.")
          exit
        end

        open("#{Reddwatch::DEFAULT_LIST_DIR}/#{list}", 'r').readlines.map do |line|
          line.strip
        end
      end
    end
  end
end
