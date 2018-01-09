require 'reddwatch'

module Reddwatch
  class Client
    def self.execute(options={})
      new(options).run
    end

    def initialize(options={})
      @options = options

      @logger   = Reddwatch::Logger
      @notifier = Reddwatch::Notifier::LibNotify.new
    end

    def run
      %w( start stop status subscribe list unsubscribe clear llist create watch
          delete restart print).each do |s|
        if @options[s.to_sym] then
          @logger.log("DEBUG: in client##{s}.")

          # Create a new socket for each command.
          # This fixes the issue where the client would stall because the server
          # was waiting for a new socket connection before reading the command.
          @sock = Reddwatch::Socket.new
          send(s)
        end
      end
      clean_up
    end

    def start
      write('START')
    end

    def stop
      write('STOP')
    end

    def subscribe
      write("SUBSCRIBE #{@options[:subscribe].join(',')}")
    end

    def unsubscribe
      write("UNSUBSCRIBE #{@options[:unsubscribe].join(',')}")
    end

    def clear
      write('CLEAR')
    end

    def create
      write("CREATE #{@options[:create]}")
    end

    def watch
      write("WATCH #{@options[:watch]}")
    end

    def delete
      write("DELETE #{@options[:delete]}")
    end

    def restart
      write('RESTART')
    end

    def status
      @logger.log 'before write'
      write('STATUS')
      @logger.log 'after write'
      # This is blocking somehow
      res = read
      puts res
    end

    def list
      write('LIST')
      puts read.gsub(',', "\n")
    end

    def llist
      write('LLIST')
      puts read.gsub(',', "\n")
    end

    def print
      write('PRINT')
      puts read
    end

    private
      
      def write(cmd)
        @logger.log("DEBUG: write(#{cmd})")
        @sock.write(cmd)
      end

      def read
        @sock.read
      end

      def clean_up
        @sock.close
      end
  end
end
