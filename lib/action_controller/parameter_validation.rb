module ActionController
  class InvalidParameters < StandardError
  end

  module ParameterValidation
    extend ActiveSupport::Concern

    included do
      rescue_from( ActionController::InvalidParameters ) do | parameter_exception |
        render \
          :text   => 'Invalid parameters',
          :status => :bad_request
      end

      before_filter :___validate_parameters
      attr_reader :validated_params
    end

    def ___param_validation_klass
      self.class.const_get :"#{ params[ :action ].classify }ParamsValidator"
    end

    def ___param_validation_klass_exists?
      !!___param_validation_klass
    rescue NameError
      false
    end

    def ___validate_parameters
      if ___param_validation_klass_exists?
        validator = ___param_validation_klass.new params
        raise InvalidParameters unless validator.validate
        @validated_params = validator.params
      end
    end
  end
end
