# DESIGN

## Reddwatch::Base (?)
reddwatch start
reddwatch stop
reddwatch help|-h|--help
reddwatch status (??)

## Reddwatch::Client (?)
reddwatch --list-lists
reddwatch --create-list <LIST>
reddwatch --watch-list <LIST>
reddwatch --delete-list <LIST>

## Reddwatch::List
reddwatch --list-watching
reddwatch --subscribe|--watch <SUBREDDIT|MULTIREDDIT> <SUBREDIT|MULTIREDDIT> ...
reddwatch --unwatch <SUBREDDIT|MULTIREDDIT> <SUBREDDIT|MULTIREDDIT> ...
reddwatch --clear

* Where to save/how to persist lists? YAML/JSON/TXT ??
