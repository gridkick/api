set :branch    , 'master'
set :deploy_to , "/var/www/#{ application }/alpha-staging"
set :domain    , 'staging-api.gridkick.com'
set :rails_env , 'staging'
set :user      , 'ubuntu'

server domain , :app , :primary => true
