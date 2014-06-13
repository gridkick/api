require 'test_helper'

class InstancesController::CreateConductorTest < ActiveSupport::TestCase
  describe 'class level functionality' do
    it 'has a class method that proxies to initialization and create' do
      InstancesController::CreateConductor.must_respond_to :create
      InstancesController::CreateConductor.any_instance.expects( :create ).returns true
      InstancesController::CreateConductor.create 1 , 2
    end
  end

  describe 'instance level functionality' do
    it 'expects params and a user' do
      proc { InstancesController::CreateConductor.new }.must_raise ArgumentError
      proc { InstancesController::CreateConductor.new Hash.new }.must_raise ArgumentError
      hash = Hash.new
      user = User.new
      conductor = InstancesController::CreateConductor.new hash , user
      conductor.params.must_equal hash
      conductor.user.must_equal user
    end

    it 'builds an instance on #create' do
      params = { :service_slug => 'bogus' }
      user = User.new
      i = Instance.new
      Instance.expects( :new ).returns i
      InstancesController::CreateConductor.create params , user
    end

    it 'proxies to Instance#provision on save' do
      i = Instance.new
      i.expects( :provision ).returns true
      Instance.expects( :new ).returns i

      params = { :service_slug => 'bogus' }
      user = User.new
      c = InstancesController::CreateConductor.create params , user
      c.expects( :too_many_instances? ).returns false
      c.expects( :needs_subscription? ).returns false
      
      c.save
    end

    it 'is only allowed to provision instances if the user has not reached the max' do
      Instance.any_instance.stubs( :provision ).returns true

      params = { :service_slug => 'bogus' }
      user = User.new :max_instances => 0
      c = InstancesController::CreateConductor.create params , user
      c.save.must_equal false

      Instance.any_instance.unstub :provision
    end
  end
end
