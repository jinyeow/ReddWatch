require 'json'

require 'reddwatch/client'
require 'reddwatch/logger'
require 'reddwatch/list'
require 'reddwatch/server'
require 'reddwatch/socket_server'
require 'reddwatch/notifier/notifier'
require 'reddwatch/processor/base'
require 'reddwatch/feed/reddit'
require "reddwatch/version"


module Reddwatch
  APP_NAME            = 'ReddWatch'

  DEFAULT_CONFIG_DIR  = "#{Dir.home}/.reddwatch"
  DEFAULT_CONFIG_FILE = 'config.json'
  DEFAULT_LIST_DIR    = "#{DEFAULT_CONFIG_DIR}/list"
  DEFAULT_WATCH_LIST  = 'default.list'

  DEFAULT_PROCESSOR   = 'Base'

  PID_FILE            = '/tmp/reddwatch.pid'

  SOCK_FILE           = '/tmp/reddwatch.socket'

  def self.init
    puts "[*] Initialising #{APP_NAME}!!"

    # setup config directory - default to $HOME/.reddwatch
    unless Dir.exists? DEFAULT_CONFIG_DIR
      print "[+] -- Creating config directory: #{DEFAULT_CONFIG_DIR}..."
      Dir.mkdir DEFAULT_CONFIG_DIR
      if Dir.exists? DEFAULT_CONFIG_DIR
        Dir.chdir DEFAULT_CONFIG_DIR
        puts 'done!'
      else
        self.error_msg("couldn't create default configuration directory")
      end
    end

    # ask for client_id/client_secret and save to config.yml
    puts '[+] -- Setting Reddit client id/secret.'
    print 'Enter Reddit client id: '
    client_id = gets.strip
    print 'Enter Reddit client secret: '
    client_secret = gets.strip

    config = {
      client_id: client_id,
      client_secret: client_secret
    }

    # setup initial config file - default to $HOME/.reddwatch/config.yml
    print "[+] -- Writing initial config file: #{DEFAULT_CONFIG_DIR}/" +
      "#{DEFAULT_CONFIG_FILE}..."
    File.open(DEFAULT_CONFIG_FILE, 'w') { |f| f.write config.to_json }
    if File.exists? DEFAULT_CONFIG_FILE then
      puts 'done!'
    else
      self.error_msg("couldn't create initial configuration file")
    end

    # setup initial watch list - default to $HOME/.reddwatch/list/default.list
    unless Dir.exists? DEFAULT_LIST_DIR
      print "[+] -- Creating lists directory: #{DEFAULT_LIST_DIR}..."
      Dir.mkdir DEFAULT_LIST_DIR
      if Dir.exists? DEFAULT_LIST_DIR
        Dir.chdir DEFAULT_LIST_DIR
        puts 'done!'
      else
        self.error_msg("couldn't create list directory")
      end
    end

    print "[+] -- Writing default list file: #{DEFAULT_LIST_DIR}/" +
      "#{DEFAULT_WATCH_LIST}..."
    File.open(DEFAULT_WATCH_LIST, 'w') { |f| f.write 'ruby' }
    if File.exists? DEFAULT_WATCH_LIST then
      puts 'done!'
    else
      self.error_msg("couldn't create default watch list")
    end

    puts '[*] Init Complete!!'
  end

  private
    def error_msg(msg)
      puts 'failed!'
      puts "[!] ERROR: #{msg}."
      exit(1)
    end
end
