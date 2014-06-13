require 'test_helper'

class CredentialsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  xit "returns empty credentials if a user doesn't have any yet" do
    current_user =
      User.create \
        :email                 => Faker::Internet.email,
        :password              => 'wutwutwut',
        :password_confirmation => 'wutwutwut'

    sign_in current_user
    get :index
    response_object_for( response.body ).credentials.must_equal []
  end

  xit "returns a user's aws credentials if they are present" do
    current_user =
      User.create \
        :email                 => Faker::Internet.email,
        :password              => 'wutwutwut',
        :password_confirmation => 'wutwutwut'

    iam_user                   = ( current_user.iam_user or current_user.build_iam_user )
    iam_user.access_key_id     = 'bogus'
    iam_user.secret_access_key = 'bogus'
    iam_user.name              = 'bogus'
    iam_user.policy_json       = '{"bogus":"bogus"}'
    iam_user.save

    sign_in current_user
    get :index

    parsed_response = response_object_for response.body
    credentials = parsed_response.credentials

    assert('there are credentials since we built them'){ credentials.length >= 1 }

    aws_credentials = credentials.detect { | credential_set | credential_set[ 'kind' ] == 'aws' }
    assert('there are aws credentials'){ aws_credentials }
    aws_credentials.must_include 'access_key_id'
    aws_credentials.must_include 'secret_access_key'
  end

  def response_object_for( body )
    Map.for JSON.parse( body )
  end
end
