module Ansible 
  module Command
    extend ActiveSupport::Concern
    
    included do 
      attr_reader \
        :hosts_file_path,
        :instance
    end
    
    module ClassMethods
      def build( *args , &block )
        new( *args , &block ).to_s
      end
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
    
    def binary
      'ansible-playbook'
    end
    
    def compiled_extra_vars
      extra_vars.map do | key , val |
        "#{ key }=#{ val }"
      end.join ' '
    end
    
    def default_hash
      raise NotImplementedError
    end
    
    def playbook
      raise NotImplementedError
    end
    
    def to_s
      [
        binary,
        playbook,
        "-i #{ hosts_file_path }",
        %Q[--extra-vars '#{ compiled_extra_vars }']
      ].join ' '
    end
    
  end
end
