class InstancesController < ApplicationController
  before_filter :authenticate_user!

  def create
    conductor = CreateConductor.create instance_params , current_user

    if conductor.save
        render :json => conductor.instance, :status => :accepted
    else
      response_txt = "Error! Please try again later or contact us at founders@gridkick.com"
      render \
        :json => {error: response_txt },
        :status => :unprocessable_entity
    end
  end

  def destroy
    instance = Instance.find instance_id_param

    if instance.user_expire
      render :json => {}, :status => :accepted
    else
      response_txt = "Error! Please try again later or contact us at founders@gridkick.com"
      render :json => {error: response_txt }, :status => :unprocessable_entity
    end
  end

  def index
    state = validated_params.fetch :state
    instances = current_user.instances.in_state state

    render :json => instances
  end

  def show
    instance = current_user.instances.find instance_id_param

    if instance
      render :json => instance
    else
      render :json => {error: "Couldn't find instance with id {# instance_id_param }"}, :status => :unprocessable_entity
    end

  end

  def update
    instance = current_user.instances.find instance_id_param
    instance.name = instance_update_params[:name]
    if instance.save
      render :json => instance, :status => :accepted
    else
      render :json => {error: "Couldn't save the edits"}, :status => :unprocessable_entity
    end
  end

  protected

  def instance_id_param
    params.require :id
  end

  def instance_params
    params.require( :instance ).permit(:service_slug, :name, :availability_zone_id)
  end

  def instance_update_params
    params.require(:instance).permit(:name)
  end
end
