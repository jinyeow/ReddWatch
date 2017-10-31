require "reddwatch/version"

require 'dotenv/load'
require 'pp'

require 'forwardable'

require 'redd'
require 'gir_ffi'

module Reddwatch
  extend Forwardable

  # NOTE: The following is only a rough outline of what I want the gem to do.
  # Needs to be run on a loop with more options.

  def self.init(opts)
    pp opts
  end

  def example
    # Initialize Redd
    session = Redd.it(
      client_id: ENV['CLIENT_ID'],
      secret:    ENV['CLIENT_SECRET']
    )

    appname   = 'ReddWatch'
    subreddit = 'ruby'

    # Get new posts from subreddit
    new = session.subreddit(subreddit).new
    posts = new.children

    # Notification init
    GirFFI.setup :Notify
    Notify.init(appname)

    # Send desktop notification
    Notify::Notification.new(
      appname,
      "#{posts.first.title}: #{posts.first.url}",
      "dialog-info"
    ).show

    # posts.each do |post|
    #   Notify::Notification.new(
    #     "#{appname} - #{subreddit}",
    #     "#{post.title}\n\n#{post.url}",
    #     "dialog-info"
    #   )
    # end
  end

  #
  # Main interface
  #

  def self.start
    puts "Starting Reddwatch..."
  end

  def self.stop
    puts "Stopping Reddwatch..."
  end

  def self.status
    puts "In progress..."
  end
end
