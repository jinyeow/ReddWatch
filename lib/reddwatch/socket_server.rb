require 'socket'

require 'reddwatch/socket'

module Reddwatch
  class SocketServer
    def initialize(name="/tmp/reddwatch.socket")
      @name = name
      @server = UNIXServer.new(@name)
      # Loop to connect new clients in a separate thread
      # Thread.new { loop { sockets.push(serv.accept) } }
      #
      # Simple example of how this should work
      # sockets.each { |sock| cmd = sock.recv(50); parse_cmd(cmd); run_cmd(cmd) }
      #
      # UNIXServer can setup multiple UNIXSocket connections
      # Each conn will send/recv ONLY between the correct client and itself - solves our locking problem.
      # use c = UNIXSocket.open(file) to connect to the UNIXServer
      # c.write;c.flush;c.read;etc.
      #
      # Maybe use a begin/rescue/ensure/end ? Ensure sock.close
    end

    def accept
      s = @server.accept
      Reddwatch::Socket.new(s)
    end

    def close
      @server.close
      File.delete @name if File.exist? @name
    end
  end
end
