class PostgresProvider
  include App::Provider

  after_create do | create_status |
    case create_status
    when :success
      PostgresChangePasswordWorker.run instance.id
    else
      instance.fail_instance
    end
  end

  def self.default_password
    ENV[ 'POSTGRES_INSTANCE_PASSWORD' ]
  end
  
  def self.default_username
    ENV[ 'POSTGRES_INSTANCE_USERNAME' ]
  end
  
  def default_password
    self.class.default_password
  end

  def default_username
    self.class.default_username
  end

  def image_version
    9
  end

  def self.port
    9181
  end

  def port
    self.class.port
  end
end
