require 'test_helper'

class ServiceRequestTest < ActiveSupport::TestCase
  it 'sends notifications of enqueued service requests' do
    instance = ServiceRequest.new
    instance.must_respond_to :send_queue_notifications

    NotificationWorker.expects( :run ).with \
      instance.class.name,
      instance.id,
      :enqueued_service_request

    instance.send_queue_notifications
  end
end
