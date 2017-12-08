require 'reddwatch'

# Monkey Patch some time-related methods to Integer
# e.g. 5.seconds, 5.minutes, 5.hours # => returns the amount of seconds
Integer.class_eval {
  define_method :seconds do
    return self
  end

  define_method :minutes do
    return 60 * self
  end

  define_method :hours do
    return 60 * 60 * self
  end
}

module Reddwatch
  module Processor
    class Base
      DEFAULT_WAIT_INTERVAL = 5.seconds # time between each post notification
      DEFAULT_CHECK_TIME    = 5.minutes # time between each reddit fetch

      def self.run(list)
        self.log("EVENT: ReddWatch started.")
        list = self.get_list(list)

        reddit = Reddwatch::Feed::Reddit.new
        notifier = Reddwatch::Notifier::LibNotify.new

        feed   = reddit.fetch(list.join('+'))

        # On startup show the newest 5 posts
        feed.take(5).each do |post|
          msg = reddit.create_message(post)
          notifier.send(msg)
          sleep(DEFAULT_WAIT_INTERVAL)
        end

        last_checked = Time.now.utc.to_i

        # Main loop
        loop do
          feed.each do |post|
            if post.created_utc > last_checked then
              msg = reddit.create_message(post)
              notifier.send(msg)
              sleep(DEFAULT_WAIT_INTERVAL)
            else
              break
            end
          end
          t = Thread.new { feed = reddit.fetch(list.join('+')) }
          last_checked = Time.now.utc.to_i
          sleep(DEFAULT_CHECK_TIME)
          t.join
        end
      end

      def self.stop
        if File.exists? '/tmp/reddwatch.pid' then
          pid = open('/tmp/reddwatch.pid', 'r').readline.strip.to_i
          Process.kill("KILL", pid)
          File.delete('/tmp/reddwatch.pid')
          self.log("EVENT: ReddWatch stopped.")
          self.status
        else
          puts "ERROR: ReddWatch is not running."
          self.log("ERROR: ReddWatch is not running.")
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
          self.log("ERROR: '#{list}' list does not exist.")
          exit(1)
        end

        open("#{Reddwatch::DEFAULT_LIST_DIR}/#{list}", 'r').readlines.map do |line|
          line.strip
        end
      end

      def self.log(msg)
        File.open('/tmp/reddwatch.log', File::WRONLY|File::CREAT|File::APPEND) do |f|
          f.puts "#{Time.now.utc.to_i}:: #{msg}"
        end
      end
    end
  end
end
