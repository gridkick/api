require 'test_helper'

class InstanceTest < ActiveSupport::TestCase
  describe 'class functionality' do
    it 'belongs to a user' do
      Instance.relations.keys.must_include 'user'
    end
  end

  describe 'instance functionality' do
    it 'knows if it is a redis instance' do
      Instance.new( :service_slug => :redis ).redis?.must_equal true
    end

    it 'knows if it is a mongo instance' do
      Instance.new( :service_slug => :mongo ).mongo?.must_equal true
    end

    it 'knows if it is a postgres instance' do
      Instance.new( :service_slug => :postgres ).postgres?.must_equal true
    end

    it 'knows if it is a mysql instance' do
      Instance.new( :service_slug => :mysql ).mysql?.must_equal true
    end

    it 'knows if it is an all instance' do
      Instance.new( :service_slug => :all ).all?.must_equal true
    end
    
    it 'daily_backups_enabled defaults to true' do 
      Instance.new.daily_backups_enabled.must_equal true
    end

    it 'notifies users of failure' do
      NotificationWorker.expects( :run ).returns true
      Instance.new.notify_user_of_failure
    end

    it 'notifies users of success' do
      NotificationWorker.expects( :run ).returns true
      Instance.new.notify_user_of_success
    end

    it 'notifies users of expiration' do
      NotificationWorker.expects( :run ).returns true
      Instance.new.notify_user_of_expiration
    end

    it 'can be expired by users' do
      ExpireWorker.expects( :run ).returns true
      Instance.new(:state => 'running').user_expire
    end

    it 'notifies users of expiration' do
      NotificationWorker.expects( :run ).returns true
      Instance.new.notify_user_of_user_expiration
    end
  end
end
