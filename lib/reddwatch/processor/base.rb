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
      DEFAULT_CHECK_TIME    = 1.minutes # time between each reddit fetch

      def initialize(opts = {})
        @options  = opts
        @list     = List.new({name: @options[:watch]})

        @logger   = Reddwatch::Logger
        @reddit   = Reddwatch::Feed::Reddit.new
        @notifier = Reddwatch::Notifier::LibNotify.new

        @running  = false
      end

      def run
        @logger.log("EVENT: ReddWatch started.")
        list = @list.list

        feed   = @reddit.fetch(list.join('+'))

        # On startup show the newest 5 posts
        feed.take(10).reverse.each do |post|
          msg = @reddit.create_message(post)
          @notifier.send(msg)
          sleep(DEFAULT_WAIT_INTERVAL)
        end

        last_checked   = feed.first.created_utc
        new_post_found = true # this is needed to prevent last_checked being updated
                              # unneccesarily on every loop.
        @running       = true

        # Main loop
        begin
          while @running do
            last_checked += 1 if new_post_found
            new_post_found = false
            feed.reverse.each do |post|
              @logger.log(
                "DEBUG: created_utc: #{post.created_utc} | last_checked: #{last_checked}"
              )
              if post.created_utc >= last_checked
                last_checked   = post.created_utc
                new_post_found = true
                msg            = @reddit.create_message(post)
                @notifier.send(msg)
                sleep(DEFAULT_WAIT_INTERVAL)
              end
            end

            @logger.log('EVENT: fetching new posts.')
            t = Thread.new { feed = @reddit.fetch(list.join('+')) }
            sleep(DEFAULT_CHECK_TIME)
            t.join
            Thread.pass
          end
        rescue Exception => e
          @logger.log("DEBUG: #{e}")
          @logger.log("EVENT: getting new access_token.")
          @reddit = Reddwatch::Feed::Reddit.new
          @logger.log("EVENT: new Reddit session started.")
          @logger.log("EVENT: retry-ing 'Main loop'.")
          retry
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

        msg[:content] = "Running..." if File.exist? Reddwatch::PID_FILE

        @notifier.send(msg)
        return msg[:content].split('.').first.downcase
      end

      def restart(opts)
        @options = opts
        @running = false
        @logger.log("EVENT: Reddwatch stopped.")
        @logger.log("EVENT: restarting server...")
        @list = List.new({name: @options[:watch]})
        run
      end
    end
  end
end
