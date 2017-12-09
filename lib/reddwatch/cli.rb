require 'reddwatch'

module Reddwatch
  class CLI
    DEFAULT_PROCESSOR   = 'Base'

    PID_FILE            = '/tmp/reddwatch.pid'
    FIFO_FILE           = '/tmp/reddwatch.fifo'

    def self.execute(options={})
      new(options).run
    end

    def initialize(options={})
      @options = options

      @notifier = Reddwatch::Notifier::LibNotify.new

      @watching = @options[:watch] || Reddwatch::DEFAULT_WATCH_LIST
      @processor = Reddwatch::Processor.const_get(DEFAULT_PROCESSOR)
        .new({list: @watching})
    end

    def run
      daemonize and start if @options[:start]
      stop if @options[:stop]
      status if @options[:status]
    end

    def start
      msg = {
        title: "#{Reddwatch::APP_NAME} - Status",
        content: "Starting #{Reddwatch::APP_NAME}...",
        level: 'dialog-info'
      }
      @notifier.send(msg)
      if start_service then
        msg[:content] = "Startup complete."
        @notifier.send(msg)
        Thread.new { @processor.run }

        @working = true
        while @working do
          sleep 1
          unless File.empty? FIFO_FILE then
            cmd = open(FIFO_FILE, 'r').readline.strip
            input = parse_cmd(cmd)

            puts input[:cmd]

            case input[:cmd]
            when "START"
              Thread.new { @processor.run }
            when "STOP"
              @working = false
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
        File.delete(PID_FILE)
        File.delete(FIFO_FILE)
        msg[:content] = "Startup failed."
        @notifier.send(msg)
      end
    end

    def parse_cmd(line)
      cmd,_ = /^([A-Z]+)(.*)/.match(line).captures
      {
        cmd: cmd
      }
    end

    def stop
      File.open(FIFO_FILE, 'w') { |f| f.write 'STOP' }
    end

    def status
      File.open(FIFO_FILE, 'w') { |f| f.write 'STATUS' }
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
        File.open(PID_FILE, 'w') { |f| f.write(pid) }
      end

      def start_service
        # check for FIFO_FILE
        if File.exists? FIFO_FILE then
          return false
        else # if it doesn't exist, this becomes the main process
          # create FIFO_FILE
          File.open(FIFO_FILE, 'w') {}
          return true
        end
      end

      def clear_fifo
        File.open(FIFO_FILE, 'w') {}
      end
  end
end
