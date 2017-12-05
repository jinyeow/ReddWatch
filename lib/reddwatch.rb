require "reddwatch/version"

require 'forwardable'

require 'reddwatch/cli'
require 'reddwatch/list'
require 'reddwatch/notifier/notifier'
require 'reddwatch/processor/base'
require 'reddwatch/feed/reddit'

module Reddwatch
  extend Forwardable

  APP_NAME              = 'ReddWatch'
  DEFAULT_CONFIG_DIR    = 'tmp'       # TODO: change this.
  DEFAULT_WATCH_LIST    = 'default'
  DEFAULT_CLI_PROCESSOR = 'Base'

  def self.init
    # setup config directory - default to $HOME/.reddwatch
    # setup initial config file - default to $HOME/.reddwatch/config.yml
    # setup initial watch list - default to $HOME/.reddwatch/list/default
    #
    # ask for client_id/client_secret and save to config.yml
  end

  def self.start
    Reddwatch::CLI.execute({start: true})
  end

  def self.stop
    Reddwatch::CLI.execute({stop: true})
  end

  def self.status
    Reddwatch::CLI.execute({status: true})
  end
end
