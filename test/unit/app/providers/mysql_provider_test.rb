require 'test_helper'

class MysqlProviderTest < ActiveSupport::TestCase
  it 'is an application provider' do
    MysqlProvider.ancestors.include? App::Provider
  end

  it 'is on version 6' do
    MysqlProvider.new( Instance.new ).image_version.must_equal 6
  end

  it 'runs on port 9191' do
    MysqlProvider.new( Instance.new ).port.must_equal 9191
  end

  it 'provides default username' do
    i = MysqlProvider.new Instance.new
    i.must_respond_to :default_username
  end

  it 'fetches the default username from ENV if present' do
    cache = ENV[ 'MYSQL_INSTANCE_USERNAME' ]
    val = 'val'
    ENV[ 'MYSQL_INSTANCE_USERNAME' ] = val

    i = MysqlProvider.new Instance.new
    i.default_username.must_equal val

    ENV[ 'MYSQL_INSTANCE_USERNAME' ] = cache
  end

  it 'provides a default password' do
    i = MysqlProvider.new Instance.new
    i.must_respond_to :default_password
  end

  it 'fetches the default password from ENV if present' do
    cache = ENV[ 'MYSQL_INSTANCE_PASSWORD' ]
    val = 'val'
    ENV[ 'MYSQL_INSTANCE_PASSWORD' ] = val

    i = MysqlProvider.new Instance.new
    i.default_password.must_equal val

    ENV[ 'MYSQL_INSTANCE_PASSWORD' ] = cache
  end
end
