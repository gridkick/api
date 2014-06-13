require 'test_helper'

class ServiceRequestMailerTest < ActionMailer::TestCase
  ##
  # Build a bunch of tests for all combinations of service request
  #
  # See: test/support/service_requests.rb
  #
  ServiceRequests.combinations.each do | scope , kinds |
    describe "service request emails for #{ scope }" do
      kinds.each do | kind |
        test_code = ServiceRequests.enqueued_email_test_for binding
        instance_eval test_code , __FILE__ , __LINE__
      end
    end
  end
end
