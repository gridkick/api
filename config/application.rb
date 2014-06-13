require File.expand_path('../boot', __FILE__)

%w(
  action_controller
  action_mailer
).each do | framework |
  require "#{ framework }/railtie"
end

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module AdventureApi
  class Application < Rails::Application
    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    I18n.enforce_available_locales = false

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Always use minitest
    config.generators do |g|
      g.test_framework :mini_test, :spec => true, :fixture => false
    end

    %w(
      lib/action_controller/parameters.rb
      lib/action_controller/parameter_validation.rb
      lib/ansible/**/*.rb
      lib/app.rb
      lib/app/**/*.rb
      lib/credentials/**/*.rb
      lib/cloud_hosts_data.rb
      lib/states.rb
    ).each do | custom_require_splat |
      Dir[ custom_require_splat ].each do | custom_require_path |
        require "#{ config.root }/#{ custom_require_path }"
      end
    end

    # Load local environment data if it is present
    envfile = "#{ config.root }/.env"
    if File.exists?( envfile )
      require 'foreman/env'
      Foreman::Env.new( envfile ).entries do | key , value |
        ENV[ key ] = value if ENV[ key ].blank?
      end
    end

    config.api_only = false
  end
end
