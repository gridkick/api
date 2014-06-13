class IAMUserSerializer < ActiveModel::Serializer
  attributes \
    :access_key_id,
    :id,
    :kind,
    :secret_access_key,
    :bucket_name

  def kind
    :aws
  end

  def id
    access_key_id
  end

  def bucket_name
    App.s3_backups_bucket.name
  end
end
