require "reddwatch/version"

require 'dotenv/load'

require 'redd'
require 'gir_ffi'

module Reddwatch
  # Your code goes here...
  # see https://github.com/Inityx/robi for an example app.

  # NOTE: The following is only a rough outline of what I want the gem to do.
  # Needs to be run on a loop with more options.
  # See TODO.md for more things to add.

  # Initialize Redd
  Redd.it(
    client_id: ENV['CLIENT_ID'],
    secret:    ENV['CLIENT_SECRET']
  )

  appname   = 'RedditWatcher'
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

  posts.each do |post|
    Notify::Notification.new(
      "#{appname} - #{subreddit}",
      "#{post.title}\n\n#{post.url}",
      "dialog-info"
    )
  end
end
