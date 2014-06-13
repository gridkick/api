require_dependency 'instances_controller' unless defined?( InstancesController )

class InstancesController
  class IndexParamsValidator
    include App::ParamValidator

    DEFAULT_PERMITTED_STATES = %w(
      active
      inactive
    ).concat ::Instance::STATES.values

    def current_state
      current_params.permit( state_key ).fetch(
        state_key,
        default_state
      ).presence or default_state
    end

    def default_state
      'active'
    end

    def permitted_states
      DEFAULT_PERMITTED_STATES
    end

    def set_params_with_new_state!( state )
      state_hash = { :state => state }
      @params = current_params.merge( state_hash )
    end

    def state_key
      :state
    end

    def validate
      state = current_state
      return false unless permitted_states.include?( state )
      set_params_with_new_state! state
      true
    end
  end
end
