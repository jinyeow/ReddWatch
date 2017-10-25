require "reddit_watcher/version"

require 'dotenv/load'

require 'redd'
require 'gir_ffi'

module RedditWatcher
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

  # Get new posts from subreddit
  new = session.subreddit('ruby').new
  posts = new.children

  # Send desktop notification
  GirFFI.setup :Notify
  Notify.init("RedditWatcher")
  Notify::Notification.new(
    "RedditWatcher",
    "#{posts.first.title}: #{posts.first.url}",
    "dialog-info"
  ).show
end
