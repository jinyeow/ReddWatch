require 'reddwatch'
require 'redd'

require_relative 'base'

module Reddwatch
  module Feed
    class Reddit
      CLIENT_ID_KEY     = "client_id"
      CLIENT_SECRET_KEY = "client_secret"

      def initialize
        @config = read_config
        @session = Redd.it(
          client_id: @config[CLIENT_ID_KEY],
          secret:    @config[CLIENT_SECRET_KEY]
        )
      end

      def fetch(subs='')
        @session.subreddit(subs).new.children
      end

      def create_message(post)
        {
          title: "#{Reddwatch::APP_NAME} - r/#{post.subreddit.display_name}",
          content: "#{post.title}",
          level: 'dialog-info'
        }
      end

      private
        def read_config
          config = "#{DEFAULT_CONFIG_DIR}/#{DEFAULT_CONFIG_FILE}"
          f = File.read(config)
          JSON.parse(f)
        end
    end
  end
end
