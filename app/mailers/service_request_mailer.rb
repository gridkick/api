class ServiceRequestMailer < ActionMailer::Base
  default :from => 'founders@gridkick.com'

  def enqueued_email( service_request )
    @service_request = service_request
    @subject = "We have received your service request [##{ service_request.id }]"

    mail \
      :to      => service_request.user.email,
      :bcc     => 'servicerequests@gridkick.com',
      :subject => @subject
  end

private

  def partial_name
    "service_request_mailer/#{ action_name }/#{ @service_request.scope }/#{ @service_request.kind }"
  end
  helper_method :partial_name
end
