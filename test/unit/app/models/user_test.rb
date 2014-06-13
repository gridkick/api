require 'test_helper'

class UserTest < ActiveSupport::TestCase
  describe 'class functionality' do
    it 'inherits from App::Model' do
      User.ancestors.must_include App::Document
    end

    it 'has many instances' do
      User.relations.keys.must_include 'instances'
    end
  end

  describe 'instance functionality' do
    it 'returns default max instances if value is falsy' do
      user = User.new :max_instances => nil
      user.max_instances.must_equal User::DEFAULT_MAX_INSTANCES

      user = User.new :max_instances => false
      user.max_instances.must_equal User::DEFAULT_MAX_INSTANCES
    end

    it 'knows when it has exceeded their max instances' do
      user = User.new :max_instances => 0
      user.max_instances_reached?.must_equal true

      user.max_instances = 1
      user.max_instances_reached?.must_equal false
    end
  end
end
