module App
  module SqlChangePasswordWorker
    extend ActiveSupport::Concern

    included do
      include App::Worker
      attr_reader :instance

      class InvalidForeignInstanceDataError < StandardError; end
      class InvalidHostError                < StandardError; end
      class InvalidPasswordError            < StandardError; end
      class InvalidPortError                < StandardError; end
      class InvalidUserError                < StandardError; end
      class PasswordNotChangedError         < StandardError; end
    end

    def change_password!
      raise NotImplementedError
    end

    def connection
      raise NotImplementedError
    end
    
    def db_hash 
      foreign_instance_data.select{ |hash| hash['type'] == db_name }.first
    end
      
    def db_host
      db_hash['host']
    rescue KeyError
      raise InvalidHostError
    end
    
    def db_password
      db_hash['password']
    rescue KeyError
      raise InvalidPasswordError
    end

    def db_port
      db_hash['port']
    rescue KeyError
      raise InvalidPortError
    end

    def db_username
      db_hash['username']
    rescue KeyError
      raise InvalidUserError
    end

    def foreign_instance_data
      instance.foreign_instance_data or raise InvalidForeignInstanceDataError
    end

    def new_random_password
      @_new_random_password ||= SecureRandom.hex 25
    end
    
    def instance_for( instance_id )
      Instance.find instance_id  
    end
    
    def perform( instance_id )
      @instance = instance_for instance_id
      
      if change_password!
        persist_new_password_for( instance_id, new_random_password )
        
        if instance.daily_backups_enabled
          EnableDailyBackupsWorker.run(instance_id) 
        end
      else
        error_message = "Unable to change password for Instance #{ instance_id }"
        error         = PasswordNotChangedError.new error_message

        raise error
      end
    end
    
    def persist_new_password_for( instance_id , password )
      instance = instance_for instance_id
      db_hash = instance.foreign_instance_data.select{ |hash| hash['type'] == db_name }.first
      db_hash[ 'password' ] = password
      
      instance.save!
      
      instance.finish
    end
    
    def retry_until_finished( name = :default )
      success = false
      max_retries = 42
      retries = 0

      loop do
        break if retries >= max_retries
        retries += 1

        success =
          if block_given?
            begin
              yield
            rescue Exception => e
              false
            end
          else
            true
          end

        break if success

        sleep rand * retries
      end

      success
    end
  end
end
