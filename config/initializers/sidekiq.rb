require 'sidekiq/web'

if (Rails.env == 'development')
  #require 'sidekiq/testing/inline' #use if you need to debug using binding.pry
end


config_block = proc do | config |
  config.redis = {
    :namespace => "adv_#{ Rails.env }"
  }
end

Sidekiq.configure_client &config_block
Sidekiq.configure_server &config_block

Sidekiq::Web.use(
  Rack::Auth::Basic,
  "Adventure API Sidekiq [#{ Rails.env }]"
) do | username , password |
  username == ENV[ 'SIDEKIQ_USERNAME' ] && password == ENV[ 'SIDEKIQ_PASSWORD' ]
end
