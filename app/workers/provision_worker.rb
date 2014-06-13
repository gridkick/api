class ProvisionWorker
  include App::Worker

  attr_reader :instance

  def perform( instance_id )
    fetch_instance instance_id
    provision_for
  end

  def fetch_instance( instance_id )
    begin
      @instance = Instance.find instance_id
    rescue Mongoid::Errors::DocumentNotFound => e
    end
  end

  def provision_for
    return false unless instance
    begin
      case
      when instance.redis?
        RedisProvider.create instance
      when instance.mongo?
        MongoProvider.create instance
      when instance.postgres?
        PostgresProvider.create instance
      when instance.mysql?
        MysqlProvider.create instance
      when instance.all?
        AllProvider.create instance
      else
        instance.fail_instance
      end
    rescue Exception => e
      instance.fail_instance
    end
  end

end
