require 'test_helper'

class InstancesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
     @current_user =
      User.create \
        :email                 => Faker::Internet.email,
        :password              => 'wutwutwut',
        :password_confirmation => 'wutwutwut',
        :authentication_token  => 'auth_key',
        :accepted_terms        => true

    sign_in @current_user
  end

  it 'creates new instances' do

    post_data = {
      :instance => { :service_slug => 'slug' },
    }

    InstancesController::CreateConductor.any_instance.expects( :save ).returns true

    post \
      :create,
      post_data

    response.code.to_i.must_equal 202
    assert('response not empty'){ response.body.length > 0 }

  end

  it 'errors if subscription is not active' do
     subscription = @current_user.build_subscription
     subscription.customer_id = "123"
     subscription.status = nil
     subscription.save!

     post_data = {
      :instance => { :service_slug => 'slug' },
    }

    post \
      :create,
      post_data

    response.code.to_i.must_equal 422
  end

  it 'errors if there is no subscription' do
     post_data = {
      :instance => { :service_slug => 'slug' },
    }

    post \
      :create,
      post_data

    response.code.to_i.must_equal 422
  end

  it 'errors if no service_slug is provided' do

    post_data = {}
    post :create, post_data
    response.code.to_i.must_equal 400
  end

  it 'allows new instance if user has subscription override flag' do
    @current_user.max_instances = 1
    @current_user.subscription_override = true
    @current_user.save

    post_data = {
      :instance => { :service_slug => 'slug' },
    }

    post \
      :create,
      post_data

    response.code.to_i.must_equal 202
    assert('response not empty'){ response.body.length > 0 }
  end

  it 'errors if unable to save the instance' do

    post_data = {
      :instance => { :service_slug => 'slug' }
    }

    InstancesController::CreateConductor.any_instance.expects( :save ).returns false

    post \
      :create,
      post_data

    response.code.to_i.must_equal 422

  end

  it 'errors if a user has created too many instances' do

    post_data = {
      :instance => { :service_slug => 'slug' }
    }

    @current_user.max_instances = 0
    @current_user.save!

    post \
      :create,
      post_data

    response.code.to_i.must_equal 422

  end

  it 'errors if a bad state param is passed when querying for instances' do

    get_data = {
      :state => :wut
    }

    get \
      :index,
      get_data

    response.code.to_i.must_equal 400

  end

  it 'can show a user a list of instances' do

    @current_user.instances.create \
      :foreign_instance_data => {
        'host' => '1.2.3.4',
        'port' => '1000'
      },
      :service_slug => 'redis'

    #not working...
    # bogus_key = 'bogus_key'
    # @current_user.instances.create \
      # :foreign_instance_data => {
        # 'host' => '1.2.3.5',
        # 'port' => '2000',
        # bogus_key => ''
      # },
      # :service_slug => 'bogus'

    get :index

    response.code.to_i.must_equal 200
    response.body.must_match /#{ @current_user.instances.first.id }/
    #response.body.wont_match /#{ bogus_key }/

    @current_user.instances.destroy_all
    @current_user.destroy
  end

  it 'deletes an instance' do

    instance =
      @current_user.instances.build \
        :foreign_instance_data => {
          'host' => '1.2.3.4',
          'port' => '1000'
        },
        :service_slug => 'redis',
        :state => 'running'

    delete_data = {
      :id => instance.id
    }

    Instance.expects( :find ).returns instance
    instance.expects( :user_expire ).returns true

    delete \
      :destroy,
      delete_data

    response.code.to_i.must_equal 202

    Instance.expects( :find ).returns instance
    instance.expects( :user_expire ).returns false

    delete \
      :destroy,
      delete_data

    response.code.to_i.must_equal 422

  end
end
