class CloudHostSerializer < ActiveModel::Serializer
  attributes :id, :name, :slug
  has_many :data_centers, embed: :objects
end
