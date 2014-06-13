require 'erb'
require 'test_helper'

class ServiceRequestsController
  class CreateParamsValidatorTest < ActiveSupport::TestCase
    describe 'class functionality' do
      it 'fills out custom filters with default/boilerplate params' do
        klass.must_respond_to :full_filters_for
        custom_filters = [ :custom ]
        full_param_filters = klass.full_filters_for *custom_filters

        assert do
          full_param_filters.any? do | filter |
                filter.is_a?( Hash ) \
            and filter.must_include( :data ) \
            and filter[ :data ].must_equal( custom_filters )
          end
        end
      end

      it 'builds method names based on scope and kind' do
        scope = 'scope'
        kind = 'kind'

        method_name =
          klass.validation_method_for \
            scope,
            kind

        method_name.must_match /#{ scope }/
        method_name.must_match /#{ kind }/
      end

      it 'builds validation methods given some specific data' do
        scope = 'scope'
        kind = 'kind'

        method_name =
          klass.validation_method_for \
            scope,
            kind

        klass.instance_methods.wont_include method_name
        klass.validator_for scope , kind , :custom
        klass.instance_methods.must_include method_name
      end
    end

    describe 'instance functionality' do
      it 'knows how to validate params based on scope/kind' do
        scope = 'scope'
        kind = 'kind'

        validator =
          instance_for \
            :scope => scope,
            :kind => kind

        method_name = validator.current_validation_method

        method_name.must_match /#{ scope }/
        method_name.must_match /#{ kind }/
      end

      ##
      # Build a bunch of tests for all combinations of service request
      # params
      #
      # See: test/support/service_requests.rb
      #
      ServiceRequests.combinations.each do | scope , kinds |
        describe scope do
          kinds.each do | kind |
            test_code = ServiceRequests.param_validator_test_for binding
            instance_eval test_code , __FILE__ , __LINE__
          end
        end
      end

      it 'returns false when validating an unkown scope or kind' do
        # unknown scope AND kind
        instance_for(
          :scope => :bogus,
          :kind  => :bogus
        ).validate.must_equal false

        # known scope AND unknown kind
        instance_for(
          :scope => :addons,
          :kind  => :bogus
        ).validate.must_equal false
      end

      def instance_for( *params )
        klass.new *params
      end
    end

    def klass
      ServiceRequestsController::CreateParamsValidator
    end
  end
end
