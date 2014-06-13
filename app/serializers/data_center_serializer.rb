class DataCenterSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug, :cloud_host_id
  has_many :availability_zones, embed: :objects
end
