class AvailabilityZonesController < ApplicationController
  def show
    zone = AvailabilityZone.find availability_zone_id_param
    render :json => zone
  end

  def availability_zone_id_param
    params.require :id
  end

end

