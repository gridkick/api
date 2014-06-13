class ServiceRequest
  include App::Document

  field \
    :scope,
    :type => String

  field \
    :kind,
    :type => String

  field \
    :request_data,
    :type => Hash

  belongs_to :instance
  belongs_to :user

  STATES =
    States.for *%w(
      initialized
      queued
      working
      fulfilled
      failed
    )

  state_machine :initial => STATES.initialized do
    STATES.values.each do | s |
      state s
    end

    event :queue do
      transition STATES.initialized => STATES.queued
    end

    after_transition \
      :on => :queue,
      :do => :send_queue_notifications

    ##
    # EXAMPLES
    #

    # after_transition \
    #   STATES.provisioning => STATES.running,
    #   :do => :notify_user_of_success

    # event :user_expire do
    #   transition STATES.running => STATES.expired
    # end
  end

  def send_queue_notifications
    NotificationWorker.run \
      self.class.name,
      id,
      :enqueued_service_request
  end
end
