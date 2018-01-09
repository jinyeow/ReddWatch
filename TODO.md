# TODO

Updated at: 12:11 09/01/18
NOTE: use r/all to test the app because it gets updated with new posts regularly.

* Add a loop in Client to parse ALL the ARGS passed to Reddwatch
* Fix error where server dies when 'reddwatch --server' is called but a server already
    exists.
* Split Processor::Base#run into multiple methods. Especially the loop to fetch and
    check.
* Add tests
* Use YAML/TOML for the config file
* Add how to get client-id/secret to README.md to get the gem working.
* Update 'Usage' in README.md
* Send me an e-mail at the start/end of each day/week of the most popular posts
* figure out if a daemon process can restart itself

# PENDING ISSUES
* While running reddwatch I noticed that there was a stage when the reddwatch
  polybar module would keep querying (reddwatch -P) but the feed wouldn't run.
  I added a begin/rescue to find out why but it's hard to see when/why it would happen.
  Keep track of the log file using 'tail -F #{logfile}' and debug.
  The issue is due to needing to refresh every hour
  Added a begin/rescue.
  When the access_token expires it will raise an exception when we try to fetch
  posts using it.
  The rescue will create a new Reddit session via Reddwatch::Feed::Reddit.new
  and then retry to start the loop again.

