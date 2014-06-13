AdventureApi::Application.routes.draw do
  
  namespace :admin do 
    get 'instances/index', as: :instances
    get 'instances' => 'instances#index'    
    
    get 'process_log/index', as: :process_logs
    get 'process_logs' => 'process_logs#index'
    
    root to: 'instances#index'
  end
    
  devise_for :users, :controllers => {:sessions => "sessions", :registrations => "registrations"}

  resources \
    :credentials,
    :only => %w( index )

  resources \
    :instances,
    :only => %w(
      create
      destroy
      index
      show
      update
    )

  resources \
    :subscriptions,
    :only => %w( index create update show destroy )

  resources \
    :providers,
    :only => %w( index )

  resources \
    :cloud_hosts,
    :only => %w( index )

  resources \
    :data_centers,
    :only => %w( show )

  resources \
    :availability_zones,
    :only => %w( show )

  # resources \
  #   :service_requests,
  #   :only => %w( create )

  resources \
    :users,
    :only => %w( show )

  resources \
    :promos,
    :only => %w( show )

  #need this for mailers so we can use root_url helper in links
  root :to => "static#home"

  mount Sidekiq::Web => '/__sidekiq__'
end
