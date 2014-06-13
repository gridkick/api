require_dependency 'instances_controller' unless defined? InstancesController

class InstancesController
  class IndexInstancesPresenter
    attr_reader :instances

    ALLOWED_FOREIGN_INSTANCE_DATA_KEYS = %w(
      host
      port
      username
      password
    )

    def self.present( instances )
      presenter = new instances
      presenter.present
    end

    def initialize( instances )
      @instances = instances
    end

    def connection_data_for( instance )
      if instance.foreign_instance_data.present?
        populated_connection_data_for instance
      else
        empty_connection_data_for instance
      end
    end

    def empty_connection_data_for( instance )
      "----> No Connection Data"
    end

    def empty_instance_output
      'NO INSTANCES'
    end

    def empty_instance_output
      'NO INSTANCES'
    end

    def host_for( instance )
      unknown = 'UNKNOWN HOST'
      instance.foreign_instance_data[ 'host' ] or unknown
    rescue
      unknown
    end

    def id_for( instance )
      unknown = 'UNKNOWN ID'
      instance.id or unknown
    rescue
      unknown
    end

    def instance_output_for( instance )
      return <<___
#{ service_slug_for instance }
--> id: #{ id_for instance }
--> state: #{ state_for instance }
--> connection:
#{ connection_data_for instance }
___
    end

    def populated_connection_data_for( instance )
      instance.foreign_instance_data.map do | k , v |
        next unless ALLOWED_FOREIGN_INSTANCE_DATA_KEYS.include?( k.to_s )
        "----> #{ k }: #{ v }"
      end.compact.join "\n"
    end

    def port_for( instance )
      unknown = 'UNKNOWN PORT'
      instance.foreign_instance_data[ 'port' ] or unknown
    rescue
      unknown
    end

    def present
      if instances.any?
        instances.map do | instance |
          instance_output_for instance
        end.join "\n"
      else
        empty_instance_output
      end
    end

    def service_slug_for( instance )
      unknown = 'UNKNOWN SERVICE'
      instance.service_slug or unknown
    rescue
      unknown
    end

    def state_for( instance )
      unknown = 'UNKNOWN STATE'
      instance.state or unknown
    rescue
      unknown
    end
  end
end
