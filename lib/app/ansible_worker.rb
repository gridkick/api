require 'systemu'

module App
  module AnsibleWorker
    extend ActiveSupport::Concern
    
    included do 
      attr_reader :instance
    end
    
    def ansible_deploy_dir
      ENV[ 'ANSIBLE_DEPLOY_DIR' ]
    end
    
    def build_hosts_file( instance )
      Ansible::InstanceHostsFile.build instance
    end

    def build_log!( process )
      log =
        ProcessLog.create! \
          :meta => {
            'jid'          => jid,
            'worker_class' => self.class.name
          },
          :notes         => '',
          :stdout        => process.stdout,
          :stderr        => process.stderr,
          :exit_status   => process.exit_status,
          :performed_for => instance

      process.log = log

      log
    end

    def cleanup!
      hosts_file.close!
    rescue Object => e
      nil
    end

    def build_command( *args )
      raise NotImplementedError
    end

    def command( instance = nil )
      @_command ||= build_command instance
    end

    def hosts_file( instance = nil )
      @_hosts_file ||= build_hosts_file instance
    end
    
    def hosts_file_path( instance = nil )
      @_hosts_file_path ||= hosts_file( instance ).path
    end

    def instance_for( instance_id )
      Instance.for instance_id
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
