require 'test_helper'

class ProvisionWorkerTest < ActiveSupport::TestCase
  it 'finds the instance given an id' do
    instance = Instance.new
    Instance.expects( :find ).returns instance

    worker = ProvisionWorker.new
    worker.expects( :provision_for ).returns true
    worker.perform instance.id
    worker.instance.must_equal instance
  end

  it "fails silently if an instance isn't found" do
    worker = ProvisionWorker.new
    Instance.expects( :find ).raises Mongoid::Errors::DocumentNotFound.new(Instance,1,1)
    worker.perform(1).must_equal false
  end

  it 'fails an instance if an error occurs during provisioning' do
    instance = Instance.new
    instance.expects( :fail_instance ).returns true
    instance.expects( :redis? ).raises RuntimeError
    Instance.expects( :find ).with( instance.id ).returns instance

    worker = ProvisionWorker.new
    worker.perform instance.id
  end

  it 'boots a redis instance if it is supposed to' do
    instance = Instance.new :service_slug => :redis
    Instance.expects( :find ).returns instance
    RedisProvider.expects( :create ).returns true

    worker = ProvisionWorker.new
    worker.perform instance.id
  end

  it "fails if it doesn't know the instance type" do
    instance = Instance.new :service_slug => :unknown
    instance.expects( :fail_instance ).returns true
    Instance.expects( :find ).returns instance

    worker = ProvisionWorker.new
    worker.perform instance.id
  end

  it 'boots a mongo instance if it is supposed to' do
    instance = Instance.new :service_slug => :mongo
    Instance.expects( :find ).returns instance
    MongoProvider.expects( :create ).returns true

    worker = ProvisionWorker.new
    worker.perform instance.id
  end

  it 'boots a postgres instance if it is supposed to' do
    instance = Instance.new :service_slug => :postgres
    Instance.expects( :find ).returns instance
    PostgresProvider.expects( :create ).returns true

    worker = ProvisionWorker.new
    worker.perform instance.id
  end

  it 'boots a mysql instance if it is supposed to' do
    instance = Instance.new :service_slug => :mysql
    Instance.expects( :find ).returns instance
    MysqlProvider.expects( :create ).returns true

    worker = ProvisionWorker.new
    worker.perform instance.id
  end

  it 'boots an all instance if it is supposed to' do
    instance = Instance.new :service_slug => :all
    Instance.expects( :find ).returns instance
    AllProvider.expects( :create ).returns true

    worker = ProvisionWorker.new
    worker.perform instance.id
  end

  it 'creates multiple foreign instance data for all providers' do
    instance = Instance.new :service_slug => :all
    Instance.expects( :find ).returns instance
    AllProvider.expects( :create ).returns true

    worker = ProvisionWorker.new
    worker.perform instance.id

  end
end
