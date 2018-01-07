# TODO

Updated at: 22:04 07/01/18
NOTE: use r/all to test the app because it gets updated with new posts regularly.

* Processor::Base is finally working right I think.
    Check that posts send notifications if created_utc > OR ==  to last_checked.
* Check that r/popular works; it didn't seem to before. Maybe with this update it will.
* Fix error where server dies when 'reddwatch --server' is called but a server already
    exists.
* Split Processor::Base#run into multiple methods. Especially the loop to fetch and
    check.
* Add a loop in Client to parse ALL the ARGS passed to Reddwatch
* Add tests
* Use YAML/TOML for the config file
* Add how to get client-id/secret to README.md to get the gem working.
* Update 'Usage' in README.md
* Send me an e-mail at the start/end of each day/week of the most popular posts
* figure out if a daemon process can restart itself

