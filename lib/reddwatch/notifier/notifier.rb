require_relative 'base'

module Reddwatch
  module Notifier
    class LibNotify < Reddwatch::Notifier::Base
      def initialize
        @name = Reddwatch::APP_NAME

        GirFFI.setup :Notify
        Notify.init(@name)
      end

      # NOTE: Default notification should be:
      # #{@name} - #{post.subreddit.display_name}
      # #{post.title}\n\n#{post.url} (maybe a description?)
      # dialog-info
      def send(msg={})
        Notify::Notification.new(
          msg[:title],
          msg[:content],
          msg[:level]
        ).show
      end
    end
  end
end
