require 'test_helper'

class App::Conductors::CreateTest < ActiveSupport::TestCase
  describe 'class functionality' do
    it 'has a create factory method that returns an instance' do
      conductor = klass
      conductor.create( {} , User.new ).must_be_a conductor
    end
  end

  describe 'instance functionality' do
    it 'accepts params and a user on instantiation' do
      proc { klass.new }.must_raise ArgumentError
      proc { klass.new Hash.new }.must_raise ArgumentError

      params = Hash.new
      user = User.new
      conductor = assert( 'no error' ){ klass.new params , user }
      conductor.params.must_equal params
      conductor.user.must_equal user
    end

    it 'errors by default on non-overridden methods' do
      params = Hash.new
      user = User.new
      conductor = assert( 'no error' ){ klass_without_overrides.new params , user }

      proc { conductor.create }.must_raise NotImplementedError
      proc { conductor.save }.must_raise NotImplementedError
    end
  end

  def klass
    Class.new do
      include App::Conductors::Create

      def create; false; end
      def save; false; end
    end
  end

  def klass_without_overrides
    Class.new do
      include App::Conductors::Create
    end
  end
end
