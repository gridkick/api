class IAMUser
  include App::Document

  belongs_to :user

  field \
    :access_key_id,
    :type => String

  field \
    :name,
    :type => String

  field \
    :policy_json,
    :type => String

  field \
    :secret_access_key,
    :type => String

  alias_method :prepared? , :valid?

  validates_presence_of \
    :access_key_id,
    :name,
    :policy_json,
    :secret_access_key

  def set_credentials!( access_key )
    self.access_key_id = access_key.access_key_id
    self.secret_access_key = access_key.secret_access_key
  end
end
