require 'systemu'

class EnableDailyBackupsWorker
  include App::Worker
  
  attr_reader :instance

  def ansible_deploy_dir
    ENV[ 'ANSIBLE_DEPLOY_DIR' ]
  end

  def build_command( instance )
    Ansible::DailyBackupsCommand.build \
      instance,
      hosts_file_path( instance )
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
        :notes         => "Ansible Daily Backups Run",
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

  def command( instance = nil )
    @_command ||= build_command instance
  end

  def enable_daily_backups_for!( instance )
    process_data =
      systemu \
        command( instance ),
        :cwd => ansible_deploy_dir

    Ansible::Process.for_systemu *process_data
  end

  def hosts_file( instance = nil )
    @_hosts_file ||= build_hosts_file instance
  end
  
  def hosts_file_path( instance = nil )
    @_hosts_file_path ||= hosts_file( instance ).path
  end

  def instance_for( i )
    Instance.for i
  end

  def perform( i )
    @instance ||= instance_for i

    log =
      retry_until_finished :enable_daily_backups do
        process = enable_daily_backups_for! instance

        build_log! process

        if process.success?
          process
        else
          false
        end
      end

    cleanup!
  end

  private

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
