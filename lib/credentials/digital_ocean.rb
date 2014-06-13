module Credentials
  module DigitalOcean
    def backend_api_client
      warn '`backend_api_client` has been deprecated -- please switch to `digital_ocean_api_client`!'
      digital_ocean_api_client
    end

    def digital_ocean_api_client
      @_digital_ocean_api_client ||=
        ::DigitalOcean::API.new \
          :api_key   => credentials.api_key,
          :client_id => credentials.client_id
    end

    def fog_api_client
      Fog::Compute.new \
        :provider               => 'DigitalOcean',
        :digitalocean_api_key   => credentials.api_key,
        :digitalocean_client_id => credentials.client_id
    end

    def credentials
      @_credentials ||=
        Map.new \
          :api_key   => ENV[ 'DIGITAL_OCEAN_API_KEY' ],
          :client_id => ENV[ 'DIGITAL_OCEAN_CLIENT_ID' ]
    end
  end
end
