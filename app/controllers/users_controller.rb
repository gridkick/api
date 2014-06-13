class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
    user = User.find user_params[:id]
    return no_user_access unless user == current_user

    render :json => current_user
  end

  def user_params
    params.permit :id
  end
  protected :user_params

  def no_user_access
    render :json=> {:success=>false, :message=>"You do not have access to this user"}, :status=>403
  end
  protected :no_user_access
end
