require 'test_helper'

class UsersController::CreateConductorTest < ActiveSupport::TestCase
  describe 'class methods' do
    it 'can be created' do
      UsersController::CreateConductor.must_respond_to :create
    end

    it 'initializes then proxies to #create' do
      UsersController::CreateConductor.any_instance.expects( :create ).returns true
      UsersController::CreateConductor.create :hi => :there
    end
  end

  describe 'instance methods' do
    it 'takes params on init' do
      proc { UsersController::CreateConductor.new }.must_raise ArgumentError
      assert( 'success with params' ){ UsersController::CreateConductor.new :hi => :there }
    end

    it 'sets a user on create' do
      User.expects( :find_or_initialize_by ).returns User.new
      conductor = UsersController::CreateConductor.new :email => ''
      conductor.create
      conductor.user.wont_be_nil
      conductor.user.must_be_a User
    end

    it 'sets email from params on create' do
      email = Faker::Internet.email
      user = User.new :email => email
      User.expects( :find_or_initialize_by ).with( :email => email ).returns user
      conductor = UsersController::CreateConductor.create :email => email
      conductor.user.must_equal user
    end

    it 'sets an api key on create' do
      User.expects( :find_or_initialize_by ).returns User.new
      conductor = UsersController::CreateConductor.create :email => ''
      conductor.user.api_key.wont_be_nil
    end

    it 'proxies to register on save' do
      User.any_instance.expects( :register ).returns true
      conductor = UsersController::CreateConductor.create :email => Faker::Internet.email
      conductor.save
    end
  end
end
