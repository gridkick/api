Rails.application.config.async =
  if ENV[ 'RAILS_ASYNC_WORKERS' ].present?
    true
  else
    case Rails.env
    when 'production' , 'staging'
      true
    else
      false
    end
  end
