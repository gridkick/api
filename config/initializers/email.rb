case ENV[ 'MAIL_SERVICE' ]
when 'mandrill'
  ActionMailer::Base.smtp_settings = {
    :user_name            => ENV[ 'MANDRILL_USERNAME' ],
    :password             => ENV[ 'MANDRILL_PASSWORD' ],
    :address              => 'smtp.mandrillapp.com',
    :port                 => 587,
    :authentication       => :login,
    :enable_starttls_auto => true
  }
else
  ActionMailer::Base.smtp_settings = {
    :user_name            => ENV[ 'SENDGRID_USERNAME' ],
    :password             => ENV[ 'SENDGRID_PASSWORD' ],
    :domain               => ENV[ 'DOMAIN' ],
    :address              => 'smtp.sendgrid.net',
    :port                 => 587,
    :authentication       => :plain,
    :enable_starttls_auto => true
  }
end
