class InstanceMailer < ActionMailer::Base
  default from: 'founders@gridkick.com'
  
  include InstancesHelper
  helper :instances
  
  def creation_email(instance)
    @instance = instance
    @service  = ( @instance.service_slug or 'redis' ).capitalize
    @info_str = "{name: #{ @instance.name }, id: #{ @instance.id }}"
    @subject  = "Your #{ instance_name(@instance) } server is up and running!"

    mail \
      :to      => instance.user.email,
      :subject => @subject
  end

  def failure_email(instance)
    @instance = instance
    @service  = ( @instance.service_slug or 'redis' ).capitalize
    @subject  = "We were unable to start a #{ instance_name(@instance) } server!"

    mail \
      :to      => instance.user.email,
      :subject => @subject,
      :bcc => "founders@gridkick.com"
  end

  def user_expiration_email(instance)
    @instance = instance
    @service  = ( @instance.service_slug or 'redis' ).capitalize
    @info_str = "(name: #{ @instance.name }, id: #{ @instance.id })"
    @subject  = "Your #{ instance_name(@instance) } server is now expired!"

    mail \
      :to      => instance.user.email,
      :subject => @subject
  end
end
