require 'reddwatch'

module Reddwatch
  class Socket
    MAX_MSG_SIZE = 200

    def initialize(name="/tmp/reddwatch.socket")
      @sock = UNIXSocket.new(name)
    end

    def write(msg)
      # @sock.puts msg
      @sock.send msg, 0
    end

    def read
      # @sock.gets
      @sock.recv MAX_MSG_SIZE
    end
    
    def close
      @sock.close
    end
  end
end
