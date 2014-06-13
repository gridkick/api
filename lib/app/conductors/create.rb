module App
  module Conductors
    module Create
      extend ActiveSupport::Concern

      included do
        attr_reader \
          :params,
          :user
      end

      module ClassMethods
        def create( *args , &block )
          conductor = new *args , &block
          conductor.create
          conductor
        end
      end

      def initialize( params , user )
        @params = params
        @user = user
      end

      def create
        raise NotImplementedError
      end

      def save
        raise NotImplementedError
      end
    end
  end
end
