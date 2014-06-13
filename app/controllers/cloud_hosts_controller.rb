class CloudHostsController < ApplicationController
  def index
    render :json => CloudHost.all
  end
end