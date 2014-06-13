require 'systemu'

class MongoChangePasswordWorker  
  
  include App::Worker
  # include Sidekiq::Worker
  # self.run
  # self.perform
  
  include App::AnsibleWorker
  # build_log!
  # build_hosts_file
  # cleanup!
  # command
  # hosts_file
  # hosts_file_path
  # instance_for instance_id
  # retry_until_finished
  # 
  # attr_reader :instance
  
  def change_mongo_password_for!( instance )
    process_data =
      systemu \
        command( instance ),
        :cwd => ansible_deploy_dir
    
    Ansible::Process.for_systemu *process_data
  end
  
  def build_command( instance )
    Ansible::MongoChangePasswordCommand.build \
      instance, 
      hosts_file_path( instance ), 
      new_db_password
  end  
  
  def perform( instance_id )
    @instance ||= instance_for instance_id
    log =
      retry_until_finished :mongo_change_password do
        process = change_mongo_password_for! instance

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
  
  # name of the mongo DB where the admin user is located
  def db_name 
    'admin'
  end
  
  def db_type
    'mongo'
  end
  
  def persist_new_password_for( instance_id , password )
    instance = instance_for instance_id
    
    instance.
      foreign_instance_data.
      select{ |hash| hash['type'] == db_type }.
      first[ 'password' ] = password
    
    instance.save!
    
    instance.finish
  end
    
end
