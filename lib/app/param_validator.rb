module App
  module ParamValidator
    extend ActiveSupport::Concern

    included do
      attr_reader \
        :original_params,
        :params
    end

    module ClassMethods
      def params_for( params )
        if params.respond_to? :require!
          params
        else
          ActionController::Parameters.new params
        end
      end
    end

    def initialize( original_params )
      @original_params = original_params
    end

    def current_params
      self.class.params_for original_params
    end
  end
end
