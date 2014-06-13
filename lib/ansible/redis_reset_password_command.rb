require 'ansible/command'

module Ansible
  class RedisResetPasswordCommand
    
    include Ansible::Command 
    # self.build
    # initialize
    # ansible_ssh_user
    # ansible_ssh_private_key_file
    # binary
    # compiled_extra_vars
    # to_s
    # 
    # attr_reader :instance
    # attr_reader :hosts_file_path
    
    attr_reader :new_db_password
    
    def initialize( instance , hosts_file_path, new_db_password )
      @instance        = instance
      @hosts_file_path = hosts_file_path
      @new_db_password = new_db_password
    end
    
    def playbook
      'redis_reset_password.yml'
    end
    
    def default_hash
      @_default_hash ||=
        {
          'ansible_ssh_user'               => ansible_ssh_user,
          'ansible_ssh_private_key_file'   => ansible_ssh_private_key_file,
          'redis_password'                 => new_db_password
        }
    end
    
    def extra_vars
      @_extra_vars ||= service_hash_for default_hash
    end
    
    def service_hash_for( default_hash )
      default_hash
    end
    
  end
end
