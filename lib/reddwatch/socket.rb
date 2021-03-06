require 'socket'

require 'reddwatch'

module Reddwatch
  class Socket
    def initialize(sock=nil, name=Reddwatch::SOCK_FILE)
      @sock = sock || UNIXSocket.new(name)
    end

    def write(msg)
      @sock.write "#{msg}\n"
    end

    def read
      @sock.readline
    end
    
    def close
      @sock.close
    end
  end
end
