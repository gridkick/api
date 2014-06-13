require 'test_helper'

class RegistrationsControllerTest < ActionController::TestCase
  it 'creates new users' do
    UsersController::CreateConductor.any_instance.expects( :save ).returns true
    email = Faker::Internet.email
    user = User.new :email => email
    User.expects( :find_or_initialize_by ).with( :email => email ).returns user
    post_data = { :user => { :email => email } }

    post \
      :create,
      post_data

    response.code.to_i.must_equal 201
    assert('response not empty'){ response.body.length > 0 }
  end

  it 'errors if no email is provided' do
    post :create
    response.code.to_i.must_equal 400
  end

  it 'errors if unable to save the user' do
    UsersController::CreateConductor.any_instance.expects( :save ).returns false
    email = Faker::Internet.email
    user = User.new :email => email
    User.expects( :find_or_initialize_by ).with( :email => email ).returns user
    post_data = { :user => { :email => email } }

    post \
      :create,
      post_data

    response.code.to_i.must_equal 422
  end
end
