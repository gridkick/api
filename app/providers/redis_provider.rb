class RedisProvider
  include App::Provider

  def image_version
    12
  end

  def self.port
    9161
  end
  
  def port
    self.class.port
  end
  
  def self.default_password
    nil
  end
  
  def self.default_username
    nil
  end
  
  def default_password
    self.class.default_password
  end
  
  def default_username
    self.class.default_username
  end

  after_create do | create_status |
    case create_status
    when :success
      RedisResetPasswordWorker.run instance.id
    else
      instance.fail_instance
    end
  end
end
