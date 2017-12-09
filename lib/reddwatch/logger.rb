module Reddwatch
  module Logger
    LOG_FILE = '/tmp/reddwatch.log'

    def self.log(msg)
      File.open(LOG_FILE, File::WRONLY|File::CREAT|File::APPEND) do |f|
        f.puts "#{Time.now.utc.to_i}:: #{msg}"
      end
    end
  end
end
