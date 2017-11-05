module Reddwatch
  class List
    def initialize(opts={})
      @name = opts[:name]

      # load_list @name
      # @subs = Read.From.Persistent.Data
    end

    # List subreddits in this list
    def list
      # puts @subs.join("\n")
    end

    # Add subs to list
    def add(subs)
      # if subs.is_a? Array then (@subs + subs).uniq else raise ArgumentError end
    end

    # Remove sub(s) from list
    def remove(subs)
      # if subs.is_a? Array then (@subs - subs) else raise ArgumentError end
    end

    # Clears the entire list.
    def clear
      # remove(@subs)
    end

    private
      def save_list
      end

      def load_list(name)
      end

      def parse_data(data)
        # JSON
      end
  end
end
