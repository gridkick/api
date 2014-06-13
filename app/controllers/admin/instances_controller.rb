class Admin::InstancesController < Admin::Base  
  def index
    @instances = Instance.where(state: Instance::ACTIVE_STATES)
  end
end
