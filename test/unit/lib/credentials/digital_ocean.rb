require 'test_helper'

class Credentials::DigitalOceanTest < ActiveSupport::TestCase
  it 'memoizes backend api client' do
    i = klass.new
    i.must_respond_to :backend_api_client
    i.backend_api_client.object_id.must_equal i.backend_api_client.object_id
  end

  it 'has a credentials map' do
    i = klass.new
    i.must_respond_to :credentials
    i.credentials.must_be_kind_of Hash
    i.credentials.must_be_a Map
    keys = i.credentials.keys.map &:to_sym
    keys.must_include :api_key
    keys.must_include :client_id
  end

  def klass
    Class.new do
      include Credentials::DigitalOcean
    end
  end
end
