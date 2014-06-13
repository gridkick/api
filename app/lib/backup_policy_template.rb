require 'erb'

class BackupPolicyTemplate
  attr_accessor \
    :bucket_name,
    :user_id

  TEMPLATE_SOURCE = <<___
{
  "Statement": [
    {
      "Sid": "bucketRelatedOperations",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:ListBucketMultipartUploads",
        "s3:ListBucketVersions"
      ],
      "Resource": "arn:aws:s3:::<%= bucket_name %>",
      "Condition": {
        "StringLike": {
          "s3:prefix": "<%= user_id %>/*"
        }
      }
    },
    {
      "Sid": "objectRelatedOperations",
      "Effect": "Allow",
      "Action": [
        "s3:*Object*",
        "s3:ListMultipartUploadParts",
        "s3:AbortMultipartUpload"
      ],
      "Resource": "arn:aws:s3:::<%= bucket_name %>/<%= user_id %>/*"
    }
  ]
}
___

  def self.result( *args , &block )
    template = new *args , &block
    template.result
  end

  def initialize( user_id , bucket_name )
    @user_id     = user_id
    @bucket_name = bucket_name
  end

  def result
    ERB.new( TEMPLATE_SOURCE ).result binding
  end
end

