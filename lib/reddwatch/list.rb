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

    # List all lists in the list_dir
    def llist
      Dir::glob("#{@list_dir}/*.list").map { |f| File.basename(f, '.list') }
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

    def name
      @name
    end

    def delete
      File.delete("#{@list_dir}/#{@name}.list")

      unless File.exists? "#{@list_dir}/#{@name}.list" then
        @logger.log("EVENT: #{@name} list deleted.")
        @subs = nil
        @name = nil
        return nil
      else
        @logger.log("ERROR: could not delete #{@name} list.")
        return self
      end

    end

    def dir
      @list_dir
    end

    def exists?
      return true if File.exists? "#{@list_dir}/#{@name}.list"
      return false
    end

    # Creates an empty list
    def self.create(options)
      list_dir = options[:list_dir] || Reddwatch::DEFAULT_LIST_DIR
      File.open("#{list_dir}/#{options[:name]}.list", 'w') {}
      new(options) # NOTE: is this needed?
    end

    # Deletes the list
    def self.delete(options)
      list_dir = options[:list_dir] || Reddwatch::DEFAULT_LIST_DIR
      name = options[:name]

      File.delete("#{list_dir}/#{name}.list")

      unless File.exists? "#{list_dir}/#{name}.list" then
        Reddwatch::Logger.log("EVENT: #{name} list deleted.")
      else
        Reddwatch::Logger.log("ERROR: could not delete #{name} list.")
      end
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
          File.open(list, 'r').readlines.map(&:strip)
        else
          @logger.log("ERROR: '#{@name}' list does not exist.")
          return nil
        end
      end
  end
end
