require 'test_helper'

class AllProviderTest < ActiveSupport::TestCase
  
  it 'is an application provider' do
    AllProvider.ancestors.include? App::Provider
  end

  it 'is on version 2' do
    AllProvider.new( Instance.new ).image_version.must_equal 2
  end

  it 'port defaults to 0' do
    AllProvider.new( Instance.new ).port.must_equal 0
  end

  it 'has postgres and redis providers' do
    AllProvider.new( Instance.new ).providers.must_equal [PostgresProvider, RedisProvider]
  end

  describe 'after_create block' do 
    describe 'when :success' do
      it 'runs Postgres change password'
      it 'runs Redis change password'
    end
    
    describe 'not :success' do
      it 'fails instance' do 
        i = Instance.new
        i.expects( :fail_instance ).returns true
        blk = Proc.new { }
        AllProvider.on_create &blk
        p = AllProvider.new i
        p.create
      end
    end
  end
end
