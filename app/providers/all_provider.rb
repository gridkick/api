class AllProvider
  include App::Provider
  
  def image_version
    2
  end

  def port
    0
  end

  def providers
    [PostgresProvider, RedisProvider]
  end
  
  after_create do |create_status|
    instance.update_attributes daily_backups_enabled: false
    
    case create_status
    when :success
      instance.finish
      PostgresChangePasswordWorker.run instance.id
      RedisResetPasswordWorker.run instance.id
    else
      instance.fail_instance
    end
  end
  
end
