require 'test_helper'

class ActionController::ParametersTest < ActiveSupport::TestCase
  it 'can require! param structure' do
    required_params =
      instance.require! \
        :key2 => {
          :nested_key2 => [ :doubly_nested_key ]
        }

    required_params[ :key1 ].must_be_nil
    required_params[ :key2 ][ :nested_key1 ].must_be_nil
  end

  it 'blows up if required key is missing at top level' do
    run_test_against_requirements :key4
  end

  it 'blows up if required key is missing in nested object' do
    requirements = { :key2 => [ :nested_key3 ] }
    run_test_against_requirements requirements

    ##
    # alternate specification
    requirements = { :key2 => :nested_key3 }
    run_test_against_requirements requirements
  end

  it 'blows up if required key is missing in array of objects' do
    requirements = { :key3 => [ :nested_key2 ] }
    run_test_against_requirements requirements

    ##
    # alternate specification
    requirements = { :key3 => :nested_key2 }
    run_test_against_requirements requirements
  end

  it 'blows up if required key is missing in nested array of objects' do
    requirements = { :key2 => { :nested_key2 => :doubly_nested_key2 } }
    run_test_against_requirements requirements

    ##
    # alternate specification
    requirements = { :key2 => { :nested_key2 => [ :doubly_nested_key2 ] } }
    run_test_against_requirements requirements
  end

  it 'allows an array of scalars' do
    requirements = { :key0 => [] }
    assert( 'no errors' ){ instance.require! requirements }
  end

  it 'allows a nested array of scalars' do
    requirements = { :key2 => { :nested_key2 => [] } }
    assert( 'no errors' ){ instance.require! requirements }
  end

  def instance
    ActionController::Parameters.new \
      :key0 => [ 1 , 2 , 3 , 4 , 5 ],
      :key1 => 'val1',
      :key2 => {
        :nested_key0 => [ 1 , 2 , 3 , 4 , 5 ],
        :nested_key1 => 'nested_val2',
        :nested_key2 => [
          { :doubly_nested_key => 'doubly_nested_val1' },
          { :doubly_nested_key => 'doubly_nested_val2' }
        ]
      },
      :key3 => [
        { :nested_key => 'doubly_nested_val1' },
        { :nested_key => 'doubly_nested_val2' }
      ]
  end

  def run_test_against_requirements( *requirements )
    proc { instance.require! *requirements }.must_raise ActionController::ParameterMissing
  end
end
