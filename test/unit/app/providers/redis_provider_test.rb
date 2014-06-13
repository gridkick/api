require 'test_helper'

class RedisProviderTest < ActiveSupport::TestCase
  it 'is an application provider' do
    RedisProvider.ancestors.include? App::Provider
  end

  it 'is on version 11' do
    RedisProvider.new( Instance.new ).image_version.must_equal 12
  end

  it 'runs on port 9161' do
    RedisProvider.new( Instance.new ).port.must_equal 9161
  end
end
