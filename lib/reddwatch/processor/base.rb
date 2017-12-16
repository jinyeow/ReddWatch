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

      def initialize(opts = {})
        @options  = opts
        @list     = @options[:list]

        @logger   = Reddwatch::Logger
        @reddit   = Reddwatch::Feed::Reddit.new
        @notifier = Reddwatch::Notifier::LibNotify.new

        @running  = false
      end

      def run
        @logger.log("EVENT: ReddWatch started.")
        list = get_list(@list)

        feed   = @reddit.fetch(list.join('+'))

        # On startup show the newest 5 posts
        feed.take(5).each do |post|
          msg = @reddit.create_message(post)
          @notifier.send(msg)
          sleep(DEFAULT_WAIT_INTERVAL)
        end

        last_checked = Time.now.utc.to_i

        @running = true

        # Main loop
        while @running do
          feed.each do |post|
            if post.created_utc > last_checked then
              msg = @reddit.create_message(post)
              @notifier.send(msg)
              sleep(DEFAULT_WAIT_INTERVAL)
            else
              break
            end
          end

          @logger.log('EVENT: fetching new posts.')
          t = Thread.new { feed = @reddit.fetch(list.join('+')) }
          last_checked = Time.now.utc.to_i
          sleep(DEFAULT_CHECK_TIME)
          t.join
        end
      end

      def stop
        begin
          if File.exists? Reddwatch::PID_FILE then
            @logger.log("EVENT: Beginning shutdown sequence.")
            File.delete(Reddwatch::PID_FILE)
            @logger.log("EVENT: deleted pid file.")
            @running = false
            @logger.log("EVENT: ReddWatch stopped.")
            status
          else
            @logger.log("ERROR: ReddWatch is not running.")
          end
        rescue Exception => e
          @logger.log("ERROR: #{e}")
        end
      end

      def status
        msg = {
          title: "#{Reddwatch::APP_NAME} - Status",
          content: 'Stopped.',
          level: 'dialog-info'
        }

        if File.exists? Reddwatch::PID_FILE then
          msg[:content] = "Running..."
        end

        @notifier.send(msg)
      end

      def restart(watching)
        @running = false
        @logger.log("EVENT: Reddwatch stopped.")
        @logger.log("EVENT: restarting server...")
        @list = watching
        run
      end

      # TODO: instead of using this use a List object to get the subs
      def get_list(list)
        unless File.exists? "#{Reddwatch::DEFAULT_LIST_DIR}/#{list}"
          @logger.log("ERROR: '#{list}' list does not exist.")
          exit(1)
        end

        open("#{Reddwatch::DEFAULT_LIST_DIR}/#{list}", 'r').readlines.map do |line|
          line.strip
        end
      end
    end
  end
end
