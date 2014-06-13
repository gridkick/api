require 'test_helper'

class App::ParamValidatorTest < ActiveSupport::TestCase
  describe 'class functionality' do
    it 'converts arbitrary hashes into params' do
      params1 = { :hi => 'there' }
      params2 = Map.for( { :hey => 'now' } )

      new_params1 = klass.params_for params1
      new_params1.object_id.wont_equal params1.object_id
      new_params1.must_respond_to :require!

      new_params2 = klass.params_for params2
      new_params2.object_id.wont_equal params2.object_id
      new_params2.must_respond_to :require!
    end

    it "doesn't convert passed params if they're already params" do
      params = ActionController::Parameters.new :hi => 'there'

      new_params = klass.params_for params
      new_params.must_equal params
    end
  end

  describe 'instance functionality' do
    it 'expects params' do
      proc { klass.new }.must_raise ArgumentError
      assert( 'now with params' ){ klass.new Hash.new }
    end

    it 'exposes passed params' do
      p = Hash.new
      instance_for( p ).original_params.object_id.must_equal p.object_id
    end

    it 'exposes newly validated params' do
      instance_for( Hash.new ).must_respond_to :params
    end

    def instance_for( *params )
      klass.new *params
    end
  end

  def klass
    Class.new do
      include App::ParamValidator
    end
  end
end
