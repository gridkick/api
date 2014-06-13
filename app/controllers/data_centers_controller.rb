class DataCentersController < ApplicationController
  def show
    data_center = DataCenter.find data_center_id_param
    render :json => data_center
  end

  def data_center_id_param
    params.require :id
  end

end

