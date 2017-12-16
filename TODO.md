# TODO

Updated at: 23:06 16/12/17

* Use TOML for the config file
* Send me an e-mail at the start/end of each day/week of the most popular posts
* Add how to get client-id/secret to README.md to get the gem working.
* Add code so that --server doesn't try to run if a server already exists.
* Add a 'show current list' command.
* Update 'Usage' in README.md
* Consider using Threads for the Client#wait_fifo_reply_and_lock and
  Server#reply_fifo_and_wait interaction.
* Consider having the --status command return a reply that is printed to stdout
  as well as the notification. Or a separate status command just for stdout.
