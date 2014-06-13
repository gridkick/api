class DataCenter
  include App::Document

  field \
    :name,
    :type => String

  field \
    :slug,
    :type => String

  belongs_to :cloud_host
  has_many :availability_zones
end
