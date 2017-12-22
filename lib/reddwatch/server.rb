require 'reddwatch'

module Reddwatch
  class Server
    def self.start
      begin
        new().run
      rescue Exception => e
        File.delete(Reddwatch::PID_FILE) if File.exists? Reddwatch::PID_FILE
        Reddwatch::Logger.log("ERROR: Server DIED :: #{e}")
        puts e.backtrace
      end
    end

    def initialize(options={})
      @options   = options

      # TODO: swap FIFO for Socket
      @fifo      = Reddwatch::FIFO.new
      @logger    = Reddwatch::Logger
      @notifier  = Reddwatch::Notifier::LibNotify.new

      @watching  = @options[:watch] || Reddwatch::DEFAULT_WATCH_LIST
      @list      = Reddwatch::List.new({name: @watching})
      @processor = Reddwatch::Processor.const_get(DEFAULT_PROCESSOR)
        .new({watch: @watching})
    end

    def run
      daemonize and running = true

      notify_status("Starting #{Reddwatch::APP_NAME}...")

      if running then
        notify_status("Startup complete.")

        Thread.new { @processor.run }

        while running do
          cmd = read_fifo
          @logger.log("DEBUG: fifo read #{cmd}.")

          input = parse_cmd(cmd)
          @logger.log("DEBUG: #{pp input}")

          process_cmd(input[:cmd], input[:args])
        end
      else
        clean_shutdown
        notify_status("Startup failed.")
      end
    end

    private

      def notify_status(msg)
        @notifier.send({
          title: "#{Reddwatch::APP_NAME} - Status",
          content: "#{msg}",
          level: 'dialog-info'
        })
      end
      
      def process_cmd(cmd, args=nil)
       case cmd
        when 'START'
          Thread.new { @processor.run }
          running = true
        when 'STOP'
          running = false
          @processor.stop
          close_fifo
        when 'STATUS'
          @processor.status
        when 'SUBSCRIBE'
          @logger.log("DEBUG: subscribe with args: #{args}")
          if @list.add(args) then
            @logger.log("DEBUG: subscribed to #{args.join(',')}")
            restart({watch: @list.name})
          end
        when 'LIST'
          @logger.log("DEBUG: list result is: #{@list.list.join(",")}")
          reply_fifo_and_wait("#{@list.list.join(",")}")
        when 'UNSUBSCRIBE'
          @logger.log("DEBUG: unsubscribe with args: #{args}")
          if @list.remove(args) then
            @logger.log('DEBUG: unsubscribe successful.')
            restart({watch: @list.name})
          end
        when 'CLEAR'
          @list.clear
        when 'CREATE'
          name = args.first
          @logger.log("DEBUG: create with args: #{name}")
          begin
            l = Reddwatch::List.create({name: name})
            @logger.log("DEBUG: #{name} list created.") if l.exists?
            l = nil
          rescue Exception => e
            @logger.log("ERROR: #{e}")
          end
        when 'WATCH'
          name = args.first
          @logger.log("DEBUG: watch with args: #{name}")
          @list = Reddwatch::List.new({name: name})
          restart({watch: name})
        when 'DELETE'
          name = args.first
          @logger.log("DEBUG: delete with args: #{name}")
          unless name.eql? Reddwatch::DEFAULT_WATCH_LIST then
            if @list.name.eql? name then
              @list = @list.delete
              if @list.nil?
                @list = Reddwatch::List.new({name: Reddwatch::DEFAULT_WATCH_LIST})
                restart({watch: Reddwatch::DEFAULT_WATCH_LIST})
              end
            else
              Reddwatch::List.delete({name: name})
            end
          else
            @logger.log("ERROR: can't delete the default list.")
          end
        when 'LLIST'
          results = @list.llist
          @logger.log("DEBUG: llist result is: #{results.join(",")}")
          reply_fifo_and_wait("#{results.join(",")}")
        when 'RESTART'
          @list = Reddwatch::List.new({name: @watching})
          restart({watch: @watching})
        when 'FULLRESTART'
          # TODO: shutdown server and re-run
        when 'PRINT'
          results = @list.name
          @logger.log("DEBUG: print result is #{results}")
          reply_fifo_and_wait(results)
        end 
      end

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

      def parse_cmd(line)
        cmd,args = /^([A-Z]+)\s?(.*)$/.match(line).captures
        {
          cmd: cmd,
          args: args.split(',')
        }
      end

      def clear_fifo
        @fifo.clear
      end

      def read_fifo
        @fifo.read.strip
      end

      def write_fifo(cmd)
        @fifo.write(cmd)
      end

      def close_fifo
        @fifo.close
        @logger.log('EVENT: closed fifo.')
      end

      def lock_fifo
        @fifo.lock
      end

      def unlock_fifo
        @fifo.unlock
      end

      def fifo_locked?
        @fifo.locked?
      end

      def reply_fifo_and_wait(msg)
        unlock_fifo
        write_fifo(msg)
        sleep 0.5 until fifo_locked?
        unlock_fifo
      end

      def clean_shutdown
        @fifo.close
        File.delete(Reddwatch::PID_FILE)
      end
      
      def restart(options)
        begin
          @logger.log('EVENT: restarting Processor::Base.run from server.')
          Thread.new { @processor.restart({watch: options[:watch]}) }
          notify_status("Restarting #{Reddwatch::APP_NAME}...\nWatching #{@list.name} list.")
        rescue Exception => e
          @logger.log("ERROR: #{e}")
        end
      end

      # TODO: figure out if a daemon process can restart itself
      def full_restart
      end
  end
end
