require 'test_helper'

class StatesTest < ActiveSupport::TestCase
  describe 'class functionality' do
    it 'is a Map' do
      States.ancestors.must_include Map
    end

    it 'can be instantiated from an array' do
      States.must_respond_to :for
      raw_states = [ :s1 , :s2 ]
      states = States.for raw_states
      states.keys.map( &:to_sym ).sort.must_equal raw_states.sort
    end

    it 'maps states to strings' do
      raw_states = [ :s1 , :s2 ]
      states = States.for raw_states
      states.values.sort.must_equal raw_states.map( &:to_s ).sort
    end
  end
end
