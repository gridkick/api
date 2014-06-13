# first middleware in the stack!
Rails.application.config.middleware.insert 0 , Rack::Cors do
  allow do
    origins  *ENV[ 'ALLOWED_CORS_ORIGINS' ].split( ',' )
    resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
  end
end
