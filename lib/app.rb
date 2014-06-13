module App
  # IAM
  mattr_accessor \
    :iam,
    :iam_group,
    :iam_user_backup_policy_name

  # S3
  mattr_accessor \
    :s3,
    :s3_backups_bucket
end
