require 'systemu'

class RedisResetPasswordWorker
  
  include App::Worker
  # include Sidekiq::Worker
  # self.run
  # self.perform
  
  include App::AnsibleWorker
  # build_hosts_file
  # build_log!
  # cleanup!
  # command
  # hosts_file
  # hosts_file_path
  # instance_for instance_id
  # retry_until_finished
  # 
  # attr_reader :instance
  
  def reset_redis_password_for!( instance )
    process_data =
      systemu \
        command( instance ),
        :cwd => ansible_deploy_dir
    
    Ansible::Process.for_systemu *process_data
  end
  
  def build_command( instance )
    Ansible::RedisResetPasswordCommand.build \
      instance, 
      hosts_file_path( instance ), 
      new_db_password
  end  
  
  def perform( instance_id )
    @instance ||= instance_for instance_id
    log =
      retry_until_finished :redis_reset_password do
        process = reset_redis_password_for! instance

        build_log! process

        if process.success?
          persist_new_password_for( instance_id, new_db_password )
          
          if instance.daily_backups_enabled
            EnableDailyBackupsWorker.run(instance_id)
          end
          
          process
        else
          false
        end
      end

    cleanup!
  end  
  
  def new_db_password
    @_new_random_password ||= SecureRandom.hex 50
  end
    
  def db_name 
    'redis'
  end
  
  def persist_new_password_for( instance_id , password )
    instance = instance_for instance_id
    
    instance.
      foreign_instance_data.
      select{ |hash| hash['type'] == db_name }.
      first[ 'password' ] = password
    
    instance.save!
    
    instance.finish
  end
    
end
