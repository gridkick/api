require 'test_helper'

class MongoProviderTest < ActiveSupport::TestCase
  it 'is an application provider' do
    MongoProvider.ancestors.include? App::Provider
  end
  
  it 'is on version 7' do
    MongoProvider.new( Instance.new ).image_version.must_equal 7
  end
  
  it 'runs on port 9171' do
    MongoProvider.new( Instance.new ).port.must_equal 9171
  end
end
