require_dependency 'service_requests_controller' unless defined?( ServiceRequestsController )

class ServiceRequestsController
  class CreateParamsValidator
    include App::ParamValidator

    DEFAULT_FILTERS = %w(
      instance_id
      scope
      kind
    )

    def self.full_filters_for( *custom_filters )
      DEFAULT_FILTERS.dup.concat [ :data => custom_filters ]
    end

    def self.validation_method_for( scope , kind )
      :"validate_#{ scope }_#{ kind }_service_request_params"
    end

    def self.validator_for( scope , kind , *custom_filters )
      validation_method_name =
        validation_method_for \
          scope,
          kind

      filters = full_filters_for *custom_filters

      define_method validation_method_name do
        @params = current_params.require! *filters
      end
    end

    def current_validation_method
      self.class.validation_method_for \
        original_params[ :scope ],
        original_params[ :kind ]
    end

    def validate
      send current_validation_method
    rescue NoMethodError
      false
    end

    validator_for \
      :addons,
      :enable_addon,
      :addon_key

    validator_for \
      :addons,
      :disable_addon,
      :addon_key

    validator_for \
      :configuration,
      :change_port,
      :port

    validator_for \
      :configuration,
      :change_key_val,
      :key,
      :value

    validator_for \
      :configuration,
      :change_file,
      :file_key,
      :file_contents

    validator_for \
      :security,
      :add_ip_address,
      :ip_address

    validator_for \
      :security,
      :remove_ip_address,
      :ip_address

    validator_for \
      :security,
      :enable_ssh_tunnel,
      :public_key

    validator_for \
      :security,
      :disable_ssh_tunnel,
      :public_key
  end
end
