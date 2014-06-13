require 'test_helper'

class PostgresProviderTest < ActiveSupport::TestCase
  it 'is an application provider' do
    PostgresProvider.ancestors.include? App::Provider
  end

  it 'is on version 9' do
    PostgresProvider.new( Instance.new ).image_version.must_equal 9
  end

  it 'runs on port 9181' do
    PostgresProvider.new( Instance.new ).port.must_equal 9181
  end

  it 'provides a default username' do
    i = PostgresProvider.new Instance.new
    i.must_respond_to :default_username
  end
  
  it 'fetches the default username from ENV if present' do
    cache = ENV[ 'POSTGRES_INSTANCE_USERNAME' ]
    val = 'val'
    ENV[ 'POSTGRES_INSTANCE_USERNAME' ] = val

    i = PostgresProvider.new Instance.new
    i.default_username.must_equal val

    ENV[ 'POSTGRES_INSTANCE_USERNAME' ] = cache
  end

  it 'provides a default password' do
    i = PostgresProvider.new Instance.new
    i.must_respond_to :default_password
  end

  it 'fetches the default password from ENV if present' do
    cache = ENV[ 'POSTGRES_INSTANCE_PASSWORD' ]
    val = 'val'
    ENV[ 'POSTGRES_INSTANCE_PASSWORD' ] = val

    i = PostgresProvider.new Instance.new
    i.default_password.must_equal val

    ENV[ 'POSTGRES_INSTANCE_PASSWORD' ] = cache
  end
end
