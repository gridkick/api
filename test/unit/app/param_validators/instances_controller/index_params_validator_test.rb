require 'test_helper'

class InstancesController
  class IndexParamsValidatorTest < ActiveSupport::TestCase
    describe 'class functionality' do
      it 'has a list of permitted states' do
        expected_list = %w(
          active
          inactive
        ).concat ::Instance::STATES.values

        klass::DEFAULT_PERMITTED_STATES.must_equal expected_list
      end
    end

    describe 'instance functionality' do
      it 'uses the passed state if present' do
        state = :wut
        i = instance_for :state => state
        i.current_state.must_equal state
      end

      it 'sets a default state if one is not passed' do
        i = instance_for
        i.current_state.must_equal i.default_state
      end

      it 'can set the validated params given a state' do
        state = :wut
        i = instance_for
        i.set_params_with_new_state! state
        i.params.fetch( :state ).must_equal state
      end

      it 'allows user provided state on validation if permitted' do
        state = 'initialized'
        i = instance_for :state => state
        i.validate.must_equal true
        i.params.fetch( :state ).must_equal state
      end

      it 'is invalid if a bad state is passed in' do
        state = 'wut'
        i = instance_for :state => state
        i.validate.must_equal false
      end

      it 'uses the default state on validation if none is provided' do
        i = instance_for
        i.validate.must_equal true
        i.params.fetch( :state ).must_equal i.default_state
      end

      it 'uses the default state if an empty state is provided' do
        state = ''
        i = instance_for :state => state
        i.validate.must_equal true
        i.params.fetch( :state ).must_equal i.default_state
      end

      def instance_for( params = Hash.new )
        klass.new params
      end
    end

    def klass
      InstancesController::IndexParamsValidator
    end
  end
end
