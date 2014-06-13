require 'test_helper'

class ExpireWorkerTest < ActiveSupport::TestCase
  it 'fails if it cannot find an instance with the given id' do
    worker = ExpireWorker.new
    assert_raise Mongoid::Errors::DocumentNotFound do
      worker.perform('bogus')
    end
  end

  it 'finds and caches an instance if one can be found' do
    worker = ExpireWorker.new
    instance = Instance.new

    worker.stubs( :fetch_instance ).returns instance
    worker.expects( :destroy! ).returns true

    worker.perform( 'bogus' ).must_equal true
  end

  it "retrieve an instance's foreign id" do
    worker = ExpireWorker.new
    instance = Instance.new :foreign_instance_data => []
    
    worker.instance_variable_set \
      :@instance,
      instance

    worker.foreign_id.must_equal false
    
    new_foreign_id = 'bogus'
    hash = { id: new_foreign_id }
    instance.foreign_instance_data.push hash
    instance.foreign_instance_data.first[ 'id' ] = new_foreign_id

    worker.foreign_id.must_equal new_foreign_id
  end

  it "knows whether an instance has a foreign id" do
    worker = ExpireWorker.new
    instance = Instance.new :foreign_instance_data => []

    worker.instance_variable_set \
      :@instance,
      instance

    worker.has_foreign_id?.must_equal false

    new_foreign_id = 'bogus'
    hash = { id: new_foreign_id }
    instance.foreign_instance_data.push hash
    instance.foreign_instance_data.first[ 'id' ] = new_foreign_id

    worker.has_foreign_id?.must_equal true
  end

  it 'can destroy an instance' do
    worker = ExpireWorker.new
    foreign_id = 'wut'
    instance = Instance.new :foreign_instance_data => [{ 'id' => foreign_id }]
    worker.stubs( :fetch_instance ).returns instance
    worker.instance_variable_set :@instance, instance
    worker.expects( :destroy_instance ).with( foreign_id ).returns false
    worker.perform instance.id
  end
end
