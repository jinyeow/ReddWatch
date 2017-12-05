require 'gir_ffi'

module Reddwatch
  module Notifier
    class Base
      def send
        raise ImplementationError, \
          "Reddwatch::Notify::Base.send has not been implemented yet"
      end
    end
  end
end
