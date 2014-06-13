class AdminMailer < ActionMailer::Base
  FOUNDERS_EMAIL = 'founders@gridkick.com'
  default \
    :from => FOUNDERS_EMAIL,
    :to   => 'notifications@gridkick.com'

  def new_user_email( user )
    @user = user
    @subject = "We've got a new user!"

    mail \
      :reply_to => [ user.email , FOUNDERS_EMAIL ],
      :subject  => @subject
  end
end
