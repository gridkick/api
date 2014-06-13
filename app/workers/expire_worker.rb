class ExpireWorker
  include App::Worker
  include Credentials::DigitalOcean
  
  attr_reader :instance

  def destroy!( instance )
    return false unless has_foreign_id?
    if destroy_instance( foreign_id )
      instance.notify_user_of_user_expiration
    end
  end

  # EXAMPLE ERROR
  #
  # {"status"=>"ERROR",
  #  "error_message"=>
  #    {"droplet"=>["There is already a pending event for the droplet"]}}
  #
  def destroy_instance( foreign_instance_id )
    if server.ready?
      success = false
      max_retries = 42
      retries = 0

      loop do
        break if retries >= max_retries

        retries += 1

        rsp =
          Map.for(
            begin
              server.destroy.body
            rescue Object => e
              eval e.message
            end
          )

        if rsp.status == 'OK'
          success = true
          break
        else
          case rsp.error_message
          when /inactive/i
            break
          end
        end

        ##
        # Backoff!
        #
        sleep rand * retries
      end
    end

    success
  end

  def foreign_id
    instance.foreign_instance_data.first[ 'id' ]
  rescue
    false
  end

  def has_foreign_id?
    !!foreign_id
  end

  def perform( instance_id )
    fetch_instance instance_id
    destroy! instance
  end

  def fetch_instance(instance_id)
    @instance = Instance.find instance_id
  end

  def server
    @_server ||= fog_api_client.servers.get foreign_id
  end
end
