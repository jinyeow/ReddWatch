require 'reddwatch'

module Reddwatch
  class Server
    SERVER_FILE = '/tmp/reddwatch.server'.freeze

    def self.start
      # NOTE: alternatively, instead of checking file existence, lock the
      #       SERVER_FILE with
      #       File.flock(File::LOCK_EX|File::LOCK_NB) and check the lock
      #       status.
      #       If it is locked File.flock will return false with File::LOCK_NB.
      #       e.g. f = File.open(SERVER_FILE, 'r');
      #            if (not f.flock(File::LOCK_EX | File::LOCK_NB) ...
      if !File.exist? SERVER_FILE
        File.open(SERVER_FILE, 'w'){}
        new.run
      else
        Reddwatch::Logger.log('DEBUG: Server already exists.')
        puts 'ReddWatch Server already up and running.'
      end
    rescue StandardError => e
      File.delete(Reddwatch::PID_FILE) if File.exist? Reddwatch::PID_FILE
      File.delete(SERVER_FILE) if File.exist? SERVER_FILE
      File.delete(SOCK_FILE) if File.exist? SOCK_FILE
      Reddwatch::Logger.log("ERROR: Server DIED :: #{e}")
      puts e.backtrace
      Reddwatch::Notifier::LibNotify.new.send(
        title: "#{Reddwatch::APP_NAME} - Status",
        content: "Server died: #{e}.",
        level: 'dialog-info'
      )
    end

    def initialize(options = {})
      @options   = options

      @serv      = Reddwatch::SocketServer.new
      @logger    = Reddwatch::Logger
      @notifier  = Reddwatch::Notifier::LibNotify.new

      @watching  = @options[:watch] || Reddwatch::DEFAULT_WATCH_LIST
      @list      = Reddwatch::List.new(name: @watching)
      @processor = Reddwatch::Processor.const_get(DEFAULT_PROCESSOR)
                                       .new(watch: @watching)
    end

    def run
      daemonize && @running = true

      notify_status("Starting #{Reddwatch::APP_NAME}...")

      if @running
        notify_status('Startup complete.')

        Thread.new { @processor.run }

        # NOTE: See below for an example on how to implement my server loop.
        # def handle_client(client)
        #   message = client.gets
        #   client.puts message
        # end
        # 
        # server = UNIXServer.new("/tmp/myapp.sock")
        # while client = server.accept?
        #   spawn handle_client(client)
        # end
        while @running && (sock = @serv.accept)
          sleep 1
          cmd = read(sock)

          @logger.log("DEBUG: read #{cmd}")

          input = parse_cmd(cmd)
          @logger.log("DEBUG: #{pp input}")

          result = process_cmd(input[:cmd], input[:args])
          @logger.log("DEBUG: #{pp result}") unless result.nil?

          reply(sock, result) if result.is_a? String
        end
      else
        clean_shutdown
        notify_status('Startup failed.')
      end
    end

    private

    def notify_status(msg)
      @notifier.send(
        title: "#{Reddwatch::APP_NAME} - Status",
        content: msg.to_s,
        level: 'dialog-info'
      )
    end

    def process_cmd(cmd, args = nil)
      res = nil
      case cmd
      when 'START'
        Thread.new { @processor.run }
        @running = true
      when 'STOP'
        @running = false
        @processor.stop
        clean_shutdown
      when 'STATUS'
        res = @processor.status
      when 'SUBSCRIBE'
        @logger.log("DEBUG: subscribe with args: #{args}")
        if @list.add(args)
          @logger.log("DEBUG: subscribed to #{args.join(',')}")
          restart(watch: @list.name)
        end
      when 'LIST'
        @logger.log("DEBUG: list result is: #{@list.list.join(',')}")
        res = @list.list.join(',')
      when 'UNSUBSCRIBE'
        @logger.log("DEBUG: unsubscribe with args: #{args}")
        if @list.remove(args)
          @logger.log('DEBUG: unsubscribe successful.')
          restart(watch: @list.name)
        end
      when 'CLEAR'
        @list.clear
      when 'CREATE'
        name = args.first
        @logger.log("DEBUG: create with args: #{name}")
        begin
          l = Reddwatch::List.create(name: name)
          @logger.log("DEBUG: #{name} list created.") if l.exists?
        rescue StandardError => e
          @logger.log("ERROR: #{e}")
        end
      when 'WATCH'
        name = args.first
        @logger.log("DEBUG: watch with args: #{name}")
        @list = Reddwatch::List.new(name: name)
        restart(watch: name)
      when 'DELETE'
        name = args.first
        @logger.log("DEBUG: delete with args: #{name}")
        if !name.eql? Reddwatch::DEFAULT_WATCH_LIST
          if @list.name.eql? name
            @list = @list.delete
            if @list.nil?
              @list = Reddwatch::List.new(name: Reddwatch::DEFAULT_WATCH_LIST)
              restart(watch: Reddwatch::DEFAULT_WATCH_LIST)
            end
          else
            Reddwatch::List.delete(name: name)
          end
        else
          @logger.log("ERROR: can't delete the default list.")
        end
      when 'LLIST'
        results = @list.llist
        @logger.log("DEBUG: llist result is: #{results.join(',')}")
        res = results.join(',')
      when 'RESTART'
        @list = Reddwatch::List.new(name: @watching)
        restart(watch: @watching)
      when 'PRINT'
        results = @list.name
        @logger.log("DEBUG: print result is #{results}")
        res = results
      end
      return res
    end

    # Taken from
    # 'jstorimer.com/blogs/workingwithcode/7766093-daemon-processes-in-ruby'
    def daemonize
      if RUBY_VERSION < '1.9'
        exit(0) if fork
        Process.setsid
        exit(0) if fork
        Dir.chdir '/'
        STDIN.reopen '/dev/null'
        STDOUT.reopen '/dev/null', 'a'
        STDERR.reopen '/dev/null', 'a'
      else
        Process.daemon
      end

      pid = Process.pid
      File.open(Reddwatch::PID_FILE, 'w') { |f| f.write(pid) }
    end

    def parse_cmd(line)
      cmd, args = /^([A-Z]+)\s?(.*)$/.match(line).captures
      {
        cmd: cmd,
        args: args.split(',')
      }
    end

    def read(sock)
      sock.read.strip
    end

    def reply(sock, msg)
      sock.write(msg)
    end

    def clean_shutdown
      @serv.close
      delete_if_exists(Reddwatch::PID_FILE)
      delete_if_exists(SERVER_FILE)
    end

    def delete_if_exists(file)
      File.delete(file) if File.exist? file
    end

    def restart(options)
      @logger.log('EVENT: restarting Processor::Base.run from server.')
      Thread.new { @processor.restart(watch: options[:watch]) }
      notify_status("Restarting #{Reddwatch::APP_NAME}...\nWatching \
                    #{@list.name} list.")
    rescue StandardError => e
      @logger.log("ERROR: #{e}")
    end
  end
end
