require_dependency 'users_controller' unless defined? UsersController

class UsersController
  class CreateConductor
    include App::Conductors::Create

    def initialize( params )
      @params = params
    end

    def create
      @user = User.find_or_initialize_by :email => params[ :email ]
      user.api_key = FFI::UUID.generate_time.to_s
    end

    def save
      user.register
    end
  end
end
