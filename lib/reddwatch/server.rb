require 'reddwatch'

module Reddwatch
  class Server
    def self.start
      new().run
    end

    def initialize(options={})
      @options   = options

      @logger    = Reddwatch::Logger
      @notifier  = Reddwatch::Notifier::LibNotify.new

      @watching  = @options[:watch] || Reddwatch::DEFAULT_WATCH_LIST
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
            cmd = get_cmd
            input = parse_cmd(cmd)

            puts input[:cmd]

            case input[:cmd]
            when "START"
              Thread.new { @processor.run }
              running = true
            when "STOP"
              running = false
              @processor.stop
            when "STATUS"
              @processor.status
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

      def get_cmd
        open(Reddwatch::FIFO_FILE, 'r').readline.strip
      end

      def parse_cmd(line)
        cmd,_ = /^([A-Z]+)(.*)/.match(line).captures
        {
          cmd: cmd
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
  end
end
