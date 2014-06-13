require 'test_helper'

class App::DocumentTest < ActiveSupport::TestCase
  describe 'class level functionality' do
    it 'inherits from Mongoid::Document' do
      klass.ancestors.must_include Mongoid::Document
    end

    describe 'name_fields!' do
      it 'responds to name_fields!' do
        klass.must_respond_to :name_fields!
      end

      it 'provides a description' do
        klass_with_name_fields.attribute_names.must_include 'description'
      end

      it 'provides a slug' do
        klass_with_name_fields.attribute_names.must_include 'slug'
      end

      it 'provides a title' do
        klass_with_name_fields.attribute_names.must_include 'title'
      end

      it 'tracks whether name_fields! has been called' do
        k = klass
        k.must_respond_to :has_name_fields
        k.has_name_fields.must_equal false
        k.name_fields!
        k.has_name_fields.must_equal true
      end

      it 'provides a validations map' do
        k = klass_with_validations
        k.must_respond_to :validations
        k.validations.must_be_a Hash
        k.validations.keys.must_include :bogus
        k.validations[ :bogus ].must_be_an Array
      end
    end

    describe 'not_found_klass' do
      # FIXME
      it 'needs to be written' do
        skip
      end
    end

    describe 'unique!' do
      # FIXME
      it 'needs to be written' do
        skip
      end
    end
  end

  def klass
    Class.new { include App::Document }
  end

  def klass_with_name_fields
    k = klass
    k.name_fields!
    k
  end

  def klass_with_validations
    k = klass
    k.validates_presence_of :bogus
    k
  end
end
