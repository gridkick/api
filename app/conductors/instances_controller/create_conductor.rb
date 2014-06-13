require_dependency 'instances_controller' unless defined? InstancesController

class InstancesController
  class CreateConductor
    include App::Conductors::Create

    attr_reader :instance

    def create
      @instance =
        Instance.new \
          :user                 => user,
          :service_slug         => params[ :service_slug ],
          :name                 => params[ :name ],
          :availability_zone_id => params[ :availability_zone_id ]
    end

    def has_active_subscription?
      user.subscription.present? && user.subscription.is_active?
    end

    def has_subscription_override?
      user.subscription_override?
    end

    def needs_subscription?
      !has_subscription_override? and !has_active_subscription?
    end

    def save
      return false if too_many_instances?
      return false if needs_subscription?

      instance.provision
    end

    def too_many_instances?
      user.max_instances_reached?
    end
  end
end
