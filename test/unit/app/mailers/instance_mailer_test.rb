require 'test_helper'

class InstanceMailerTest < ActionMailer::TestCase
  describe 'sends instance creation failure emails for' do
    it 'all server' do
      service = 'all'
      user = 'ryan@gridkick.com'

      i = Instance.new :service_slug => service
      i.build_user :email => user

      email = InstanceMailer.failure_email( i ).deliver

      ActionMailer::Base.deliveries.must_include email
      email.from.must_include 'founders@gridkick.com'
      email.to.must_include user

      body = email.text_part.body.to_s
      body.must_include('we were unable to boot a Postgres + Redis')
    end
    
    it 'mysql server' do 
      service = 'mysql'
      user = 'ryan@gridkick.com'

      i = Instance.new :service_slug => service
      i.build_user :email => user

      email = InstanceMailer.failure_email( i ).deliver

      ActionMailer::Base.deliveries.must_include email
      email.from.must_include 'founders@gridkick.com'
      email.to.must_include user

      body = email.text_part.body.to_s
      body.must_include('we were unable to boot a mysql')
    end
  end

  it 'sends instance creation success emails' do
    service = 'redis'
    host = '1.2.3.4'
    port = 9161
    user = 'ryan@gridkick.com'

    i =
      Instance.new \
        :service_slug => service,
        :foreign_instance_data => [{
          'type' => 'redis',
          'host' => host,
          'port' => port,
        }]

    i.build_user :email => user

    email = InstanceMailer.creation_email( i ).deliver

    ActionMailer::Base.deliveries.must_include email
    email.from.must_include 'founders@gridkick.com'
    email.to.must_include user

    body = email.text_part.body.to_s
    body.must_match /host: #{ host }/i
    body.must_match /port: #{ port }/i
    body.must_match /pong/i
  end

  it 'has some redis specific data' do
    service = 'redis'
    host = '1.2.3.4'
    port = 9161
    user = 'ryan@gridkick.com'
    password = 'abc'

    i =
      Instance.new \
        :service_slug => service,
        :foreign_instance_data => [{
          'type' => 'redis,',
          'host' => host,
          'port' => port,
          'password' => password
        }]

    i.build_user :email => user

    email = InstanceMailer.creation_email( i ).deliver

    body = email.text_part.body.to_s
    body.must_match /pong/i
    body.wont_include(password)
  end

  it 'has some mongo specific data' do
    service = 'mongo'
    host = '1.2.3.4'
    port = 9171
    user = 'ryan@gridkick.com', 
    username = 'mongo-username'
    password = 'mongo-password'

    i =
      Instance.new \
        :service_slug => service,
        :foreign_instance_data => [{
          'type' => 'mongo',
          'host' => host,
          'port' => port,
          'username' => username,
          'password' => password,
        }]

    i.build_user :email => user

    email = InstanceMailer.creation_email( i ).deliver

    body = email.text_part.body.to_s
    body.must_include("#{host}:#{port}/admin")
    body.must_include("--username #{username}")
    body.wont_include(password)
  end

  it 'has some postgres specific data' do
    service = 'postgres'
    host = '1.2.3.4'
    port = 9171
    username = 'postgresuser'
    password = 'postgrespassword'

    user = 'ryan@gridkick.com'

    i =
      Instance.new \
        :service_slug => service,
        :foreign_instance_data => [{
          'type' => 'postgres',
          'host' => host,
          'port' => port,
          'username' => username,
          'password' => password
        }]

    i.build_user :email => user

    email = InstanceMailer.creation_email( i ).deliver

    body = email.text_part.body.to_s
    body.must_match /#{ username }/i
    body.must_include("Password: Get it by logging into your")
    body.wont_include(password)
  end
  
  it 'has some mysql specific data' do
    service = 'mysql'
    host = '1.2.3.4'
    port = 9171
    username = 'mysqluser'
    password = 'mysqlpassword'

    user = 'ryan@gridkick.com'

    i =
      Instance.new \
        :service_slug => service,
        :foreign_instance_data => [{
          'type' => 'mysql',
          'host' => host,
          'port' => port,
          'username' => username,
          'password' => password
        }]

    i.build_user :email => user

    email = InstanceMailer.creation_email( i ).deliver

    body = email.text_part.body.to_s
    body.must_match /#{ username }/i
    body.must_include("Password: Get it by logging into your")
    body.wont_include(password)
  end
  
  it 'has some all specific data' do 
    service = 'all'
    host    = '1.2.3.4' 
    
    user = 'ryan@gridkick.com'
    
    i = 
      Instance.new \
        :service_slug => service, 
        :foreign_instance_data => [
          {
            'host'      => host,
            'type'      => 'redis', 
          }, 
          {
            'host'      => host, 
            'type'      => 'postgres',
          }
        ]
    
    i.build_user :email => user
    
    email = InstanceMailer.creation_email( i ).deliver
    
    body = email.text_part.body.to_s
    body.must_include "Please login into your GridKick Account, https://gridkick.com/databases, to see database credentials."
    
    email.subject.must_include "Postgres + Redis"
  end
  
  describe 'sends instance expiration emails for' do
    it 'all server' do 
      service = 'all'
      user = 'ryan@gridkick.com'

      i = Instance.new :service_slug => service
      i.build_user :email => user

      email = InstanceMailer.user_expiration_email( i ).deliver

      ActionMailer::Base.deliveries.must_include email
      email.from.must_include 'founders@gridkick.com'
      email.to.must_include user

      body = email.text_part.body.to_s
      body.must_match /Postgres \+ Redis/
    end
    
    it 'mysql server' do 
      service = 'mysql'
      user = 'ryan@gridkick.com'

      i = Instance.new :service_slug => service
      i.build_user :email => user

      email = InstanceMailer.user_expiration_email( i ).deliver

      ActionMailer::Base.deliveries.must_include email
      email.from.must_include 'founders@gridkick.com'
      email.to.must_include user

      body = email.text_part.body.to_s
      body.must_match /Mysql/i
    end
  end
  
  describe 'sends user instance expiration emails for' do
    it 'all server' do
      service = 'all'
      user = 'ryan@gridkick.com'

      i = Instance.new :service_slug => service
      i.build_user :email => user

      email = InstanceMailer.user_expiration_email( i ).deliver

      ActionMailer::Base.deliveries.must_include email
      email.from.must_include 'founders@gridkick.com'
      email.to.must_include user

      body = email.text_part.body.to_s
      body.must_match /#{ i.id }/i
      body.must_match /expired/i
      body.must_match /Postgres \+ Redis/i
    end
    
    it 'mysql server' do 
      service = 'mysql'
      user = 'ryan@gridkick.com'

      i = Instance.new :service_slug => service
      i.build_user :email => user

      email = InstanceMailer.user_expiration_email( i ).deliver

      ActionMailer::Base.deliveries.must_include email
      email.from.must_include 'founders@gridkick.com'
      email.to.must_include user

      body = email.text_part.body.to_s
      body.must_match /#{ i.id }/i
      body.must_match /expired/i
      body.must_match /Mysql/i
    end
  end
end
