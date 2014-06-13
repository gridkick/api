require 'ansible/command'

module Ansible
  class MongoChangePasswordCommand
    
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
      'mongo_change_password.yml'
    end
    
    def db_type
      'mongo'
    end
    
    def db_hash 
      instance.
        foreign_instance_data.
        select{ |hash| hash['type'] == db_type }.
        first
    end
    
    def default_hash
      @_default_hash ||=
        {
          'ansible_ssh_user'               => ansible_ssh_user,
          'ansible_ssh_private_key_file'   => ansible_ssh_private_key_file,
        }
    end
    
    def extra_vars
      @_extra_vars ||= service_hash_for default_hash
    end
    
    def service_hash_for( default_hash )
      service_hash = { 
        'db_name'     => 'admin', 
        'db_username' => db_hash['username'],
        'db_password' => db_hash['password'],
        'db_port'     => db_hash['port'],
        'new_random_password' => new_db_password
      }
      
      default_hash.merge(service_hash)
    end
    
  end
end
