aws_access_key_id     = ENV.fetch 'AWS_ACCESS_KEY_ID'
aws_secret_access_key = ENV.fetch 'AWS_SECRET_ACCESS_KEY'
aws_region            = ENV.fetch 'AWS_REGION'

AWS.config \
  :access_key_id     => aws_access_key_id,
  :secret_access_key => aws_secret_access_key,
  :region            => aws_region

App.iam            = AWS::IAM.new
aws_iam_group_name = "gridkick-#{ Rails.env }-users"
group_does_exist   = App.iam.groups.enumerator.any? { | group | group.name == aws_iam_group_name }

App.iam_group =
  if group_does_exist
    App.iam.groups[ aws_iam_group_name ]
  else
    App.iam.groups.create aws_iam_group_name
  end

App.s3                       = AWS::S3.new
aws_s3_backups_bucket_name   = "gridkick-#{ Rails.env }-backups"
s3_backups_bucket_does_exist = App.s3.buckets.any? { | bucket | bucket.name == aws_s3_backups_bucket_name }

App.s3_backups_bucket =
  if s3_backups_bucket_does_exist
    App.s3.buckets[ aws_s3_backups_bucket_name ]
  else
    App.s3.buckets.create aws_s3_backups_bucket_name
  end

aws_iam_user_backup_policy_name = ENV.fetch 'AWS_IAM_USER_BACKUP_POLICY_NAME'
App.iam_user_backup_policy_name = aws_iam_user_backup_policy_name
