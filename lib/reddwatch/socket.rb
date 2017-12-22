module Reddwatch
  class Socket
    def initialize
      # TODO
      # Maybe have a SocketServer class?
      # @serv = UNIXServer.new('/Some/path/to/server')
      # @sockets = Queue.new || []
      #
      # Loop to connect new clients
      # loop { sockets.push(serv.accept) }
      #
      # Simple example of how this should work
      # sockets.each { |sock| cmd = sock.recv(50); parse_cmd(cmd); run_cmd(cmd) }
      #
      # UNIXServer can setup multiple UNIXSocket connections
      # Each conn will send/recv ONLY between the correct client and itself - solves our locking problem.
      #
      # Maybe use a begin/rescue/ensure/end ? Ensure sock.close
    end

    def write
    end

    def read
    end

    def close
      @sockets.each { |sock| sock.close }
      @serv.close
    end
  end
end
