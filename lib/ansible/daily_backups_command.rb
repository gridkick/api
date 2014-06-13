module Ansible
  class DailyBackupsCommand
    attr_reader \
      :hosts_file_path,
      :instance

    def self.build( *args , &block )
      new( *args , &block ).to_s
    end

    def initialize( instance , hosts_file_path )
      @instance        = instance
      @hosts_file_path = hosts_file_path
    end

    def ansible_ssh_user
      'gridkickbackup'
    end

    def ansible_ssh_private_key_file
      ENV[ 'BACKUPS_PRIVATE_KEY_PATH' ]
    end

    def app_db_password
      instance.foreign_instance_data.first[ 'password' ]
    end

    def app_db_port
      instance.foreign_instance_data.first[ 'port' ]
    end

    def app_db_username
      instance.foreign_instance_data.first[ 'username' ]
    end

    def app_environment
      Rails.env.to_s
    end

    def app_iam_access_key_id
      iam_user.access_key_id
    end

    def app_iam_secret_access_key
      iam_user.secret_access_key
    end

    def app_instance_id
      instance.id.to_s
    end

    def app_user_id
      user.id.to_s
    end

    def backup_notifier_mail_user_name
      ENV[ 'MANDRILL_USERNAME' ]
    end

    def backup_notifier_mail_password
      ENV[ 'MANDRILL_PASSWORD' ]
    end

    def backup_service
      service_for( instance )
    end

    def binary
      'ansible-playbook'
    end

    def compiled_extra_vars
      extra_vars.map do | key , val |
        "#{ key }=#{ val }"
      end.join ' '
    end

    def default_hash
      @_default_hash ||=
        {
          'ansible_ssh_user'               => ansible_ssh_user,
          'ansible_ssh_private_key_file'   => ansible_ssh_private_key_file,
          'app_db_password'                => app_db_password,
          'app_db_port'                    => app_db_port,
          'app_db_username'                => app_db_username,
          'app_environment'                => app_environment,
          'app_iam_access_key_id'          => app_iam_access_key_id,
          'app_iam_secret_access_key'      => app_iam_secret_access_key,
          'app_instance_id'                => app_instance_id,
          'app_user_id'                    => app_user_id,
          'backup_notifier_mail_user_name' => backup_notifier_mail_user_name,
          'backup_notifier_mail_password'  => backup_notifier_mail_password,
          'backup_service'                 => backup_service
        }
    end

    def extra_vars
      @_extra_vars ||= service_hash_for default_hash
    end

    def iam_user
      user.iam_user
    end

    def playbook
      'daily_backups.yml'
    end

    def redis_hash_for( default_hash )
      default_hash.tap do | h |
        h[ 'app_db_data_path' ] = '/var/lib/redis'
      end
    end

    def service_for( instance )
      case instance.service_slug
      when 'postgres'
        'postgresql'
      else
        instance.service_slug
      end
    end

    def service_hash_for( default_hash )
      case service_for( instance )
      when 'redis'
        redis_hash_for default_hash
      else
        default_hash
      end
    end

    def to_s
      [
        binary,
        playbook,
        "-i #{ hosts_file_path }",
        %Q[--extra-vars '#{ compiled_extra_vars }']
      ].join ' '
    end

    def user
      instance.user
    end
  end
end
