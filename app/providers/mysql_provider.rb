class MysqlProvider
  include App::Provider

  after_create do | create_status |
    case create_status
    when :success
      MysqlChangePasswordWorker.run instance.id
    else
      instance.fail_instance
    end
  end

  def default_password
    ENV[ 'MYSQL_INSTANCE_PASSWORD' ]
  end

  def default_username
    ENV[ 'MYSQL_INSTANCE_USERNAME' ]
  end

  def image_version
    6
  end

  def self.port
    9191
  end

  def port
    self.class.port
  end
end
