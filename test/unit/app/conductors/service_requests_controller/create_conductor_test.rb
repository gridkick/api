require 'test_helper'

class ServiceRequestsController
  class CreateConductorTest < ActiveSupport::TestCase
    it 'builds a service request on create' do
      Instance.expects( :find ).returns Instance.new
      i = instance
      i.create
      i.service_request.must_be_a ServiceRequest
    end

    it 'has a default scope if one is not provided' do
      i = instance
      i.must_respond_to :default_scope
      i.default_scope.must_be_truthy
    end

    it 'has a default kind if one is not provided' do
      i = instance
      i.must_respond_to :default_kind
      i.default_kind.must_be_truthy
    end

    def instance
      ServiceRequestsController::CreateConductor.new \
        parameters,
        user
    end

    def parameters
      ActionController::Parameters.new \
        :instance_id => 'abc123',
        :scope => 'addons',
        :kind => 'enable_addon',
        :data => {
          :addon_key => 'hourly_backups'
        }
    end

    def user
      User.new :email => Faker::Internet.email
    end
  end
end
