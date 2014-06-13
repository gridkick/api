module App
  module Worker
    extend ActiveSupport::Concern

    included do
      include Sidekiq::Worker
    end

    module ClassMethods
      def perform( *args )
        new.perform *args
      end

      def run( *args )
        method =
          if Rails.application.config.async
            :perform_async
          else
            :perform
          end

        send method , *args
      end
    end
  end
end
