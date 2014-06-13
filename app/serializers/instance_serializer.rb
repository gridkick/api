class InstanceSerializer < ActiveModel::Serializer
  attributes :id, :foreign_instance_data, :created_at, :state, :service_slug, :name, :availability_zone_id
end
