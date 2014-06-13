require 'test_helper'

class NotificationWorkerTest < ActiveSupport::TestCase
  describe 'class functionality' do
    it 'has a list of allowed notifications' do
      NotificationWorker.constants.must_include :ALLOWED_NOTIFICATIONS
    end
  end

  describe 'instance functionality' do
    it 'vivifies an instance when run' do
      user = User.new
      User.expects( :find ).returns user
      NotificationWorker.any_instance.expects( :send_notification_for ).returns true

      worker = NotificationWorker.new
      worker.perform \
        'User',
        'random id',
        :notification_type

      worker.instance.must_equal user
    end

    it 'vivifies an instance given a class name and id' do
      user = User.new
      User.expects( :find ).returns user

      worker = NotificationWorker.new
      i =
        worker.instance_for \
          'User',
          'random id'

      i.must_equal user
    end

    it 'converts notification types to method names' do
      worker = NotificationWorker.new
      worker.notification_method_for( :thing ).must_equal :thing_email_for
    end

    it "raises an error if it doesn't know about a notification" do
      worker = NotificationWorker.new
      proc { worker.send_notification_for :thing }.must_raise NotificationWorker::UnknownNotificationTypeError
    end

    it 'calls the specific method for a notification with the instance' do
      worker = NotificationWorker.new
      worker.stubs( :instance ).returns User.new
      notification_type = :new_instance
      mail_stub = mock
      mail_stub.expects :deliver
      worker.expects( worker.notification_method_for( notification_type ) ).returns mail_stub
      worker.send_notification_for notification_type
    end

    it "doesn't raise an exception if the notification type is a string" do
      worker = NotificationWorker.new
      worker.stubs( :instance ).returns User.new
      notification_type = 'new_instance'
      mail_stub = mock
      mail_stub.expects :deliver
      worker.expects( worker.notification_method_for( notification_type ) ).returns mail_stub
      worker.send_notification_for notification_type
    end

    describe 'specific notifications' do
      it 'sends new instance emails to users' do
        instance = Instance.new
        NotificationWorker::ALLOWED_NOTIFICATIONS.must_include :new_instance
        InstanceMailer.expects( :creation_email ).with( instance ).returns true
        worker = NotificationWorker.new
        worker.new_instance_email_for instance
      end

      it 'sends failed instance emails to users' do
        instance = Instance.new
        NotificationWorker::ALLOWED_NOTIFICATIONS.must_include :failed_instance
        InstanceMailer.expects( :failure_email ).with( instance ).returns true
        worker = NotificationWorker.new
        worker.failed_instance_email_for instance
      end

      it 'sends instance user expiration emails to users' do
        instance = Instance.new
        NotificationWorker::ALLOWED_NOTIFICATIONS.must_include :instance_user_expiration
        InstanceMailer.expects( :user_expiration_email ).with( instance ).returns true
        worker = NotificationWorker.new
        worker.instance_user_expiration_email_for instance
      end

      it 'sends enqueued service request emails to users' do
        service_request = ServiceRequest.new
        NotificationWorker::ALLOWED_NOTIFICATIONS.must_include :enqueued_service_request
        ServiceRequestMailer.expects( :enqueued_email ).with( service_request ).returns true
        worker = NotificationWorker.new
        worker.enqueued_service_request_email_for service_request
      end
      
      # TODO share
      xit 'sends new share emails to users' do
        share = Share.new
        NotificationWorker::ALLOWED_NOTIFICATIONS.must_include :new_share
        ShareMailer.expects( :share_email ).with( share ).returns true
        worker = NotificationWorker.new
        worker.new_share_email_for share
      end
    end
  end
end
