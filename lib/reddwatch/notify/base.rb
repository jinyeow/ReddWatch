module Reddwatch
  module Notify
    class Base
      def send
        raise ImplementationError, \
          "Reddwatch::Notify::Base.send has not been implemented yet"
      end
    end
  end
end
