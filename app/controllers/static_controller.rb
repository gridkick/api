class StaticController < ApplicationController
  def home
    paths = {
      :instances => '/instances',
      :users     => '/users'
    }

    render :json => paths
  end
end
