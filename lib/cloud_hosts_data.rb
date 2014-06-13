module CloudHostsData
  extend self

  AvailabilityZone = Class.new Map
  CloudHost        = Class.new Map
  DataCenter       = Class.new Map

  CLOUD_HOSTS =
    [
      CloudHost.new(
        :name         => 'Digital Ocean',
        :slug         => 'digital-ocean',
        :data_centers => [

          DataCenter.new(
            :name               => 'Amsterdam',
            :slug               => 'amsterdam',
            :availability_zones => [
              AvailabilityZone.new(
                :name           => '1',
                :slug           => '1',
                :available      => true
              ),
              AvailabilityZone.new(
                :name           => '2',
                :slug           => '2',
                :available      => true
              )
            ]
          ),

          DataCenter.new(
            :name               => 'New York',
            :slug               => 'new-york',
            :availability_zones => [

              AvailabilityZone.new(
                :name           => '1',
                :slug           => '1',
                :available      => true
              ),

              AvailabilityZone.new(
                :name           => '2',
                :slug           => '2',
                :available      => true
              )

            ]
          ),

          DataCenter.new(
            :name               => 'San Francisco',
            :slug               => 'san-francisco',
            :availability_zones => [
              AvailabilityZone.new(
                :name           => '1',
                :slug           => '1',
                :available      => true
              )
            ]
          ), 
          
          DataCenter.new(
            :name               => 'Singapore',
            :slug               => 'singapore',
            :availability_zones => [
              AvailabilityZone.new(
                :name           => '1',
                :slug           => '1',
                :available      => true
              )
            ]
          ), 
          
        ]
      )
    ]

  def all
    CLOUD_HOSTS
  end

  def method_missing( method , *args , &block )
    if CLOUD_HOSTS.respond_to?( method )
      CLOUD_HOSTS.send \
        method,
        *args,
        &block
    else
      super
    end
  end
end
