require 'reddwatch'

module Reddwatch
  class List
    def initialize(opts={})
      @logger = Reddwatch::Logger
      @opts = opts

      @name = @opts[:name]
      @name = @name.sub(/\.list/, '') if @name =~ /[a-z]+\.list/i

      @list_dir = @opts[:list_dir] || Reddwatch::DEFAULT_LIST_DIR

      # load_list @name
      @subs = load_list(@name)
    end

    # List subreddits in this list
    def list
      @subs
    end

    # Add subs to list
    def add(subs)
      @logger.log('EVENT: in list#add.')
      @logger.log("EVENT: #{subs.class}.")
      begin
        if subs.is_a? Array then
          @subs = (@subs + subs).uniq
        elsif subs.is_a? String then
          @subs = @subs.push(subs).uniq
        else
          return false
        end

        save_list(@subs)
        return true
      rescue Exception => e
        @logger.log("ERROR: #{e}")
      end
    end

    # Remove sub(s) from list
    def remove(subs)
      if subs.is_a? Array then
        @subs = (@subs - subs)
      else
        raise ArgumentError
      end

      save_list(@subs)
    end

    # Clears the entire list.
    def clear
      @subs = []
      save_list(@subs)
    end

    def delete
      @subs = []
      File.delete("#{@list_dir}/#{@name}.list")
    end

    private
      def save_list(subs)
        File.open("#{@list_dir}/#{@name}.list", 'w') do |f|
          f.write(subs.join("\n"))
        end
      end

      def load_list(name)
        list = "#{@list_dir}/#{@name}.list"
        
        if File.exists? list then
          f = File.open(list, 'r')
          f.readlines.map { |l| l.strip }
        else
          File.open(list, 'w') {}
          []
        end
      end
  end
end
