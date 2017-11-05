require 'dotenv/load'
require 'redd'

require_relative 'base'

module Reddwatch
  module Feed
    class Reddit
      def initialize
        @session = Redd.it(
          client_id: ENV['CLIENT_ID'],
          secret:    ENV['CLIENT_SECRET']
        )
      end

      def fetch(subs='')
        @session.subreddit(subs).new.children
      end
    end
  end
end
