require "reddwatch/version"

require 'forwardable'

require 'reddwatch/cli'
require 'reddwatch/list'
require 'reddwatch/notify/notifier'
require 'reddwatch/processor/cron'
require 'reddwatch/feed/reddit'

module Reddwatch
  extend Forwardable

  APP_NAME              = 'ReddWatch'
  DEFAULT_WATCH_LIST    = 'default'
  DEFAULT_CLI_PROCESSOR = 'Cron'

end
