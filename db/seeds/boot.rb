CloudHostsData.each do | cloud_host_data |
  cloud_host =
    CloudHost.find_or_initialize_by :slug => cloud_host_data.slug

  cloud_host.name = cloud_host_data.name
  cloud_host.save!

  cloud_host_data.data_centers.each do | data_center_data |
    data_center =
      cloud_host.data_centers.find_or_initialize_by :slug => data_center_data.slug

    data_center.name = data_center_data.name
    data_center.save!

    data_center_data.availability_zones.each do | availability_zone_data |
      availability_zone =
        data_center.availability_zones.find_or_initialize_by :slug => availability_zone_data.slug

      availability_zone.name = availability_zone_data.name
      availability_zone.available = availability_zone_data.available
      availability_zone.save!
    end
  end
end
