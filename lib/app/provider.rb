module App
  module Provider
    extend ActiveSupport::Concern

    included do
      include Credentials::DigitalOcean

      attr_reader :instance

      cattr_accessor \
        :after_create_block,
        :on_create_block
    end

    def self.supported
      %w(
        mongo
        mysql
        postgres
        redis
        all
      )
    end

    module ClassMethods
      def after_create( &block )
        self.after_create_block = block
      end

      def create( instance )
        raise ArgumentError unless instance.is_a? Instance
        provider = new instance
        provider.create
      end

      def on_create( &block )
        self.on_create_block = block
      end
    end

    def initialize( instance )
      @instance = instance
    end

    def after_create( create_status )
      run! :after_create_block , create_status
    end

    def after_create_block
      self.class.after_create_block
    end

    def create
      run! :on_create_block do | status |
        after_create status
      end
    end

    def default_after_create_block
      @_default_after_create_block ||=
        proc do | create_status |
          case create_status
          when :success
            instance.finish

            if instance.daily_backups_enabled
              EnableDailyBackupsWorker.run(instance_id)
            end
          else
            instance.fail_instance
          end
        end
    end

    def default_on_create_block
      @_default_on_create_block ||=
        proc do
          image  = fetch_image
          region = fetch_region
          flavor = fetch_flavor

          if image.present? and region.present? and flavor.present?
            droplet =
              fog_api_client.servers.create \
                :image_id  => image.id,
                :name      => instance_name,
                :region_id => region.id,
                :flavor_id => flavor.id

            droplet.wait_for { ready? }

            if droplet.public_ip_address.present?
              foreign_instance_host = droplet.public_ip_address
              foreign_instance_id   = droplet.id
              status                = :success
            else
              droplet.destroy

              foreign_instance_host = ""
              foreign_instance_id   = ""
              status                = :failed
            end

            instance.foreign_instance_data ||= default_foreign_instance_data

            if providers.present?
              providers.each do |provider|
                add_foreign_instance_data(foreign_instance_host,
                                          foreign_instance_id,
                                          provider.port,
                                          instance_name,
                                          provider.name.downcase.split("provider").first,
                                          provider.default_password,
                                          provider.default_username )
              end
            else
              add_foreign_instance_data(foreign_instance_host,
                                        foreign_instance_id,
                                        port,
                                        instance_name,
                                        service,
                                        default_password,
                                        default_username )
            end
          else
            status = :failed
          end

          instance.save!
          status
        end
    end

    def default_foreign_instance_data
      []
    end

    def default_region_name
      'New York 1'
    end

    def fetch_image
      @_image ||=
        fog_api_client.images.detect { | i | i.name == image_name }
    end

    def image_name
      "adv-proto-#{ service }-snapshot-#{ image_version }"
    end

    def image_version
      1
    end

    #empty by default. AllProvider overrides with the providers that it supports
    def providers
      []
    end

    def instance_name
      "adv-#{ Rails.env.downcase.dasherize }-#{ service }-#{ instance.id }"
    end

    def on_create_block
      self.class.on_create_block
    end

    def port
      raise NotImplementedError
    end

    def fetch_region
      @_region ||=
        fog_api_client.regions.detect { | r | r.name == requested_region_name }
    end

    def region_name_for( availability_zone )
      "#{ availability_zone.data_center.name } #{ availability_zone.name }"
    end

    def requested_region_name
      @_requested_region_name =
        if instance.availability_zone.present?
          region_name_for instance.availability_zone
        else
          default_region_name
        end
    end

    def fetch_flavor
      @_flavor ||=
        fog_api_client.flavors.detect { | s | s.name == '1GB' }
    end

    def service
      instance.service_slug
    end

    def add_foreign_instance_data(host, id, port, name, type, password, username)
      foreign_data_hash = Hash.new

      foreign_data_hash[ 'host' ] = host
      foreign_data_hash[ 'id'   ] = id
      foreign_data_hash[ 'port' ] = port
      foreign_data_hash[ 'name' ] = name
      foreign_data_hash[ 'type' ] = type
      foreign_data_hash[ 'password' ] = password
      foreign_data_hash[ 'username' ] = username

      instance.foreign_instance_data.push(foreign_data_hash)
    end

    private

    def run!( block_name , *args )
      blk = ( send( block_name ) or send( :"default_#{ block_name }" ) )

      result =
        if blk.respond_to? :call
          instance_exec *args , &blk
        else
          blk
        end

      yield result if block_given?

      return result
    end
  end
end
