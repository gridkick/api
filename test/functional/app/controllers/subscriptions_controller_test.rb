require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
     @current_user =
      User.create \
        :email                 => Faker::Internet.email,
        :password              => 'wutwutwut',
        :password_confirmation => 'wutwutwut',
        :authentication_token  => 'auth_key', 
        :accepted_terms        => true

    subscription = @current_user.build_subscription({customer_id: '123', status: 'active'})
    subscription.save!

    sign_in @current_user
  end

  xit 'destroys instances when the subscription is canceled' do

    @current_user.instances.create \
      :foreign_instance_data => {
        'host' => '1.2.3.4',
        'port' => '1000'
      },
      :service_slug => 'redis',
      :name => 'redis_test',
      :state => 'running'

    @current_user.instances.create \
      :foreign_instance_data => {
        'host' => '1.2.3.4',
        'port' => '1000'
      },
      :service_slug => 'mysql',
      :name => 'mysql_test',
      :state => 'running'

    assert('user has two active instances'){ @current_user.instances.in_state('active').length == 2 }

    Subscription.any_instance.expects( :cancel ).returns true
    delete \
      :destroy,
      {id: 'singleton'}

    response.code.to_i.must_equal 202
    assert('response not empty'){ response.body.length > 0 }
    assert('user has two inactive instances'){ @current_user.instances.in_state('inactive').length == 2 }
    assert('user has zero active instances'){ @current_user.instances.in_state('active').length == 0 }

    Subscription.any_instance.expects( :cancel ).returns false
    delete \
      :destroy,
      {id: 'singleton'}

    response.code.to_i.must_equal 422

  end
end
