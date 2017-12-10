# ReddWatch
-----------

ReddWatch notifies you when there are new Posts from Subreddits that you choose.

Create a list of subreddits and ReddWatch will periodically scan r/{sub}/new of those
subreddits to check for new posts. RW will then display a desktop notification to
alert you of the new post.

## Installation

Install it yourself as:

    $ gem install reddwatch

## Usage

See `reddwatch -h` for more information.

TODO: Write usage instructions here
e.g. reddwatch --subscribe worldnews // adds r/worldnews to list of subreddits to watch
     reddwatch --list-subreddits // lists subscribed subreddits

     reddwatch --add-keywords // adds keywords that will create a 'critical' notification.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jinyeow/reddwatch.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
