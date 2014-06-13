class RegistrationsController < Devise::RegistrationsController
  include ActionController::StrongParameters

  def create
    user = User.new(user_params)
    if user.save
      user.background_create_aws_data
      user.background_notify_admin_of_creation

      sign_in(:user, user)
      data = {user: UserSerializer.new(user).serializable_hash}

      if user_params[:remember_me]
        user.remember_me!
        data[:user].merge!(:remember_token => remember_token(user))
      end

      render :json => data, :status => 201

      return
    else
      warden.custom_failure!
      render :json=> {errors: user.errors}, :status=>422
    end
  end

protected

  def remember_token(resource)
    data = resource_class.serialize_into_cookie(resource)
    "#{data.first.first}-#{data.last}"
  end

private

  def user_params
    params.require(:user).permit(:current_password, :email, :name, :password, :password_confirmation, :auth_token, :remember_me, :accepted_terms, :promo_code, :promo_description)
  end
end
