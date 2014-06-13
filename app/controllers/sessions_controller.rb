class SessionsController < Devise::SessionsController
  include ActionController::StrongParameters
  before_filter :authenticate_user!, :except => [:create]

  def create

    build_resource
    resource = if remember_params[:remember_token]
                 resource_from_remember_token
               else
                 resource_from_credentials
               end
    return invalid_login_attempt unless resource
    return invalid_login_attempt unless resource.accepted_terms?
 
    sign_in(:user, resource)
    resource.ensure_authentication_token!
    
    data = {
      user_id: resource.id,
      auth_token: resource.authentication_token,
    }
    
    if !remember_params[:remember_token] && user_login_params[:remember_me]
      resource.remember_me!
      data[:remember_token] = remember_token(resource)
    end
    
    render json: data, status: 201

  end
 
  def destroy
    current_user.reset_authentication_token!
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    render :json=> {:success=>true}
  end
 
  protected
  
  def invalid_login_attempt
    warden.custom_failure!
    render :json=> {:success=>false, :message=>"Error with your login or password"}, :status=>401
  end
  
  def remember_token(resource)
    data = resource_class.serialize_into_cookie(resource)
    "#{data.first.first}-#{data.last}"
  end

  def resource_from_remember_token
    token = remember_params[:remember_token]
    id, identifier = token.split('-')
    resource_class.serialize_from_cookie(id, identifier)
  end

  def resource_from_credentials
    if res = resource_class.find_for_database_authentication({ email: user_login_params[:email] })
      if res.valid_password?(user_login_params[:password])
        res
      end
    end
  end
  
  private
  
  def user_login_params
    params.require(:user_login).permit(:email, :password, :auth_token, :remember_me)
  end
  
  def remember_params
    params.permit(:remember_token)
  end
  
  #handle case when user_login is empty
  rescue_from ActionController::ParameterMissing do | e |
    invalid_login_attempt
  end
end
