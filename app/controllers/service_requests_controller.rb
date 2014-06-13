class ServiceRequestsController < ApplicationController
  before_filter :authenticate_user!
  
  def create
    conductor =
      CreateConductor.create \
        service_request_params,
        current_user

    if conductor.save
      response_txt = "We have received your request. You will receive an email as soon as everything is completed."
      render \
        :text   => response_txt,
        :status => :accepted
    else
      response_txt = "Error! Please try again later or contact us at founders@gridkick.com"
      render \
        :text   => response_txt,
        :status => :unprocessable_entity
    end

  rescue Mongoid::Errors::DocumentNotFound
    response_txt = "Error -- Invalid instance_id!"
    render \
      :text   => response_txt,
      :status => :not_found
  end

protected

  def service_request_params
    validated_params
  end
end
