require 'reddwatch'

module Reddwatch
  class Server
    def self.start
      begin
        new().run
      rescue Exception => e
        Reddwatch::Logger.log("ERROR: Server DIED :: #{e}")
      end
    end

    def initialize(options={})
      @options   = options

      @logger   = Reddwatch::Logger
      @notifier = Reddwatch::Notifier::LibNotify.new

      @watching  = @options[:watch] || Reddwatch::DEFAULT_WATCH_LIST
      @list      = Reddwatch::List.new({name: @watching})
      @processor = Reddwatch::Processor.const_get(DEFAULT_PROCESSOR)
        .new({list: @watching})
    end

    def run
      daemonize and start_service and running = true

      msg = {
        title: "#{Reddwatch::APP_NAME} - Status",
        content: "Starting #{Reddwatch::APP_NAME}...",
        level: 'dialog-info'
      }
      @notifier.send(msg)

      if running then
        msg[:content] = "Startup complete."
        @notifier.send(msg)

        Thread.new { @processor.run }

        while running do
          sleep 0.5
          unless File.empty? Reddwatch::FIFO_FILE then
            cmd = read_fifo
            input = parse_cmd(cmd)

            @logger.log("EVENT: caught #{input[:cmd]}.")

            case input[:cmd]
            when "START"
              Thread.new { @processor.run }
              running = true
            when "STOP"
              running = false
              @processor.stop
            when "STATUS"
              @processor.status
            when "SUBSCRIBE"
              @logger.log("EVENT: subscribe with args: #{input[:args]}")
              if @list.add(input[:args]) then
                @logger.log("EVENT: subscribed to #{input[:args].join(',')}")
              end
            when "LIST"
              @logger.log("EVENT: list result is: #{@list.list.join(",")}")
              write_fifo("#{@list.list.join("\n")}")
            when "UNSUBSCRIBE"
              @logger.log("EVENT: unsubscribe with args: #{input[:args]}")
              if @list.remove(input[:args]) then
                @logger.log('EVENT: unsubscribe successful.')
              end
            end

            # Need to check for 'STOP' otherwise the FIFO_FILE gets created
            # after we stop reddwatch which FC*Ks up the next startup of reddwatch.
            clear_fifo unless input[:cmd] == 'STOP'
          end
        end
      else
        File.delete(Reddwatch::PID_FILE)
        File.delete(Reddwatch::FIFO_FILE)
        msg[:content] = "Startup failed."
        @notifier.send(msg)
      end
    end

    private

      # Taken from 'jstorimer.com/blogs/workingwithcode/7766093-daemon-processes-in-ruby'
      def daemonize
        if RUBY_VERSION < "1.9" then
          exit(0) if fork
          Process.setsid
          exit(0) if fork
          Dir.chdir "/"
          STDIN.reopen "/dev/null"
          STDOUT.reopen "/dev/null", "a"
          STDERR.reopen "/dev/null", "a"
        else
          Process.daemon
        end

        pid = Process.pid
        File.open(Reddwatch::PID_FILE, 'w') { |f| f.write(pid) }
      end

      def read_fifo
        open(Reddwatch::FIFO_FILE, 'r').readline.strip
      end

      def parse_cmd(line)
        cmd,args = /^([A-Z]+)\s?(.*)$/.match(line).captures
        {
          cmd: cmd,
          args: args.split(',')
        }
      end

      def start_service
        # check for Reddwatch::FIFO_FILE
        if File.exists? Reddwatch::FIFO_FILE then
          return false
        else # if it doesn't exist, this becomes the main process
          # create Reddwatch::FIFO_FILE
          File.open(Reddwatch::FIFO_FILE, 'w') {}
          return true
        end
      end

      def clear_fifo
        File.open(Reddwatch::FIFO_FILE, 'w') {}
      end

      def write_fifo(cmd)
        File.open(Reddwatch::FIFO_FILE, 'w') { |f| f.write "#{cmd}" }
      end
  end
end
