class AvailabilityZone
  include App::Document

  field \
    :name,
    :type => String

  field \
    :slug,
    :type => String

  field \
    :available,
    :type => Boolean,
    :default => false

  belongs_to :data_center
end
