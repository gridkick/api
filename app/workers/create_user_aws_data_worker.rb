require 'forwardable'

class CreateUserAwsDataWorker
  include App::Worker
  extend Forwardable

  def_delegators \
    :"App",
    :iam,
    :iam_group,
    :iam_user_backup_policy_name,
    :s3_backups_bucket

  def assign_access_key_for( user , iam_user )
    iam_user.access_keys.create
  end

  def assign_iam_user_to_iam_group( iam_user )
    iam_group.users.add iam_user
  end

  def find_user!( user_id )
    User.find user_id
  end

  def assign_iam_policy_for( user , iam_user )
    iam_user.policies[ iam_user_backup_policy_name ].presence or new_iam_policy_for( user , iam_user )
  end

  def iam_user_for( user )
    iam_user_name = iam_user_name_for user
    iam.users.create iam_user_name
  rescue AWS::IAM::Errors::EntityAlreadyExists
    iam.users[ iam_user_name ]
  end

  def iam_user_name_for( user )
    "gridkick-#{ Rails.env }-user-#{ user.id }"
  end

  def new_iam_policy_for( user , iam_user )
    policy_content = templated_backup_policy_for user
    policy = AWS::IAM::Policy.from_json policy_content
    iam_user.policies[ iam_user_backup_policy_name ] = policy
  end

  def perform( user_id )
    user = find_user! user_id
    perform_iam_tasks_for( user ) unless user.has_prepared_iam_user?
  end

  def perform_iam_tasks_for( user )
    iam_user = iam_user_for user

    assign_iam_user_to_iam_group iam_user
    access_key = assign_access_key_for user , iam_user

    assign_iam_policy_for \
      user,
      iam_user

    persist_iam_data_for_user \
      user,
      iam_user,
      access_key
  end

  def persist_iam_data_for_user( user , iam_user , access_key )
    iam_user_model = ( user.iam_user or user.build_iam_user )
    iam_user_model.set_credentials! access_key
    iam_user_model.name = iam_user.name
    iam_user_model.policy_json = templated_backup_policy_for user
    iam_user_model.save!
  end

  def templated_backup_policy_for( user )
    @_policy_string ||= BackupPolicyTemplate.result user.id , s3_backups_bucket.name
  end
end
