class ProvidersController < ApplicationController
  def index
    #i.e. [{:slug=>"mongo", :id=>1}, {:slug=>"mysql", :id=>2}]
    providers = App::Provider.supported.to_enum.with_index(1).map{|val, index| {:name => val, :id => index}}
    render :json => {:providers => providers}
  end
end
