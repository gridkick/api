class MongoProvider
  include App::Provider

  def image_version
    7
  end

  def self.port
    9171
  end

  def port
    self.class.port
  end

  def self.default_password
    ENV[ 'MONGO_INSTANCE_PASSWORD' ]
  end

  def self.default_username
    ENV[ 'MONGO_INSTANCE_USERNAME' ]
  end

  def default_password
    self.class.default_password
  end

  def default_username
    self.class.default_username
  end

  after_create do |create_status|
    case create_status
    when :success
      MongoChangePasswordWorker.run instance.id
    else
      instance.fail_instance
    end
  end
end
