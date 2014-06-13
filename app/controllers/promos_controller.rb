class PromosController < ApplicationController
  def show
    promos = [{name: "f6s_30off", description: "30% off for 6 months"}]
    promo = promos.select { |p| p[:name] == params[:id]}.first

    if promo
      render :json => {promo: promo}
    else
      render :json => {error: "Invalid Promo Code"}, :status => :unprocessable_entity
    end

  end

end
