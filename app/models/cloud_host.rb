class CloudHost
  include App::Document

  field \
    :name,
    :type => String

  field \
    :slug,
    :type => String

  has_many :data_centers
end
