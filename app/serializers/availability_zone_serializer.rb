class AvailabilityZoneSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :available, :data_center_id
end
