class NotificationWorker
  include App::Worker

  attr_reader :instance

  ALLOWED_NOTIFICATIONS = [
    :new_instance,
    :failed_instance,
    :instance_user_expiration,
    :enqueued_service_request,
    :admin_new_user
  ]

  class UnknownNotificationTypeError < StandardError
    def initialize( notification_type )
      super "The #{ notification_type } notification is unknown!"
    end
  end

  def perform( klass_name , instance_id , notification_type )
    @instance =
      instance_for \
        klass_name,
        instance_id

    send_notification_for notification_type
  end

  def instance_for( klass_name , id )
    klass_name.constantize.find id
  end

  def send_notification_for( notification_type )
    if ALLOWED_NOTIFICATIONS.include?( notification_type.to_sym )
      mail =
        send \
          notification_method_for( notification_type ),
          instance

      mail.deliver
    else
      raise UnknownNotificationTypeError.new( notification_type )
    end
  end

  def notification_method_for( notification_type )
    :"#{ notification_type }_email_for"
  end

  def failed_instance_email_for( instance )
    InstanceMailer.failure_email instance
  end

  def new_instance_email_for( instance )
    InstanceMailer.creation_email instance
  end

  def instance_user_expiration_email_for( instance )
    InstanceMailer.user_expiration_email instance
  end

  def enqueued_service_request_email_for( service_request )
    ServiceRequestMailer.enqueued_email service_request
  end

  def admin_new_user_email_for( user )
    AdminMailer.new_user_email user
  end
end
