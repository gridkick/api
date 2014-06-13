require 'test_helper'

class ServiceRequestsControllerTest < ActionController::TestCase
  xit 'creates new service requests' do
    api_key = 'api-key'
    email = Faker::Internet.email

    post_data = {
      :instance_id => 'ohai',
      :scope => 'addons',
      :kind => 'enable_addon',
      :data => {
        :addon_key => 'wut',
        :other_key => 'wort'
      },
      :user => {
        :api_key => api_key,
        :email => email
      }
    }

    user = User.new :email => email , :api_key => api_key

    ServiceRequestsController.any_instance.stubs( :current_user ).returns user
    Instance.expects( :find ).returns Instance.new
    ServiceRequestsController::CreateConductor.any_instance.expects( :save ).returns true

    post \
      :create,
      post_data

    response.code.to_i.must_equal 202
    assert('response not empty'){ response.body.strip.length > 0 }

    ServiceRequestsController.any_instance.unstub :current_user
  end

  xit 'errors on bad service requests' do
    api_key = 'api-key'
    email = Faker::Internet.email

    post_data = {
      :instance_id => 'ohai',
      :scope => 'addons',
      :kind => 'enable_addon',
      :data => {
        :bad_key => 'wut',
      },
      :user => {
        :api_key => api_key,
        :email => email
      }
    }

    user = User.new :email => email , :api_key => api_key

    ServiceRequestsController.any_instance.stubs( :current_user ).returns user

    post \
      :create,
      post_data

    response.code.to_i.must_equal 400

    ServiceRequestsController.any_instance.unstub :current_user
  end

  xit 'returns a not found response if a bad instance id is present' do
    api_key = 'api-key'
    email = Faker::Internet.email

    post_data = {
      :instance_id => 'ohai',
      :scope => 'addons',
      :kind => 'enable_addon',
      :data => {
        :addon_key => 'wut'
      },
      :user => {
        :api_key => api_key,
        :email => email
      }
    }

    user = User.new :email => email , :api_key => api_key

    ServiceRequestsController.any_instance.stubs( :current_user ).returns user

    error =
      Mongoid::Errors::DocumentNotFound.new \
        Instance,
        :abc123,
        :abc123

    ServiceRequestsController::CreateConductor.expects( :create ).raises error

    post \
      :create,
      post_data

    response.code.to_i.must_equal 404

    ServiceRequestsController.any_instance.unstub :current_user
  end
end
