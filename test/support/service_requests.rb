require 'erb'

module ServiceRequests
  extend self

  def combinations
    {
      :addons => [
        [ :enable_addon  , [ :addon_key ] ],
        [ :disable_addon , [ :addon_key ] ]
      ],
      :configuration => [
        [ :change_port    , [ :port ] ],
        [ :change_key_val , [ :key , :value ] ],
        [ :change_file    , [ :file_key , :file_contents ] ]
      ],
      :security => [
        [ :add_ip_address     , [ :ip_address ] ],
        [ :remove_ip_address  , [ :ip_address ] ],
        [ :enable_ssh_tunnel  , [ :public_key ] ],
        [ :disable_ssh_tunnel , [ :public_key ] ]
      ]
    }
  end

  def enqueued_email_test_for( b = binding )
    ERB.new( enqueued_email_test_template ).result b
  end

  def enqueued_email_test_template
    %q[
      it 'sends enqueued service request emails for <%= kind[ 0 ] %>' do
        scope = :<%= scope.to_s %>
        kind = :<%= kind[ 0 ].to_s %>
        user = User.new :email => Faker::Internet.email

        instance =
          Instance.new \
            :user         => user,
            :service_slug => 'redis'

        service_request =
          ServiceRequest.new \
            :user         => user,
            :instance     => instance,
            :scope        => scope,
            :kind         => kind,
            :request_data => {
              <% kind[ 1 ].each do | required_key | %>
                :<%= required_key %> => :value,
              <% end %>
            }

        email = ServiceRequestMailer.enqueued_email( service_request ).deliver

        ActionMailer::Base.deliveries.must_include email
        email.from.must_include 'founders@gridkick.com'
        email.to.must_include user.email
        email.bcc.must_include 'servicerequests@gridkick.com'

        email.subject.must_match /#{ service_request.id }/i

        body = email.text_part.body.to_s
        body.must_match /#{ instance.id }/i
        body.must_match /#{ instance.service_slug } server/i
      end
    ]
  end

  def param_validator_test_for( b = binding )
    ERB.new( param_validator_test_template ).result b
  end

  def param_validator_test_template
    %q[
      it "validates for <%= kind[ 0 ] %>" do
        scope = :<%= scope.to_s %>
        kind = :<%= kind[ 0 ].to_s %>

        method_name =
          klass.validation_method_for \
            scope,
            kind

        klass.instance_methods.must_include method_name

        instance_for(
          :instance_id => 'abc123',
          :scope => scope,
          :kind => kind,
          :data => {
            <% kind[ 1 ].each do | required_key | %>
              :<%= required_key %> => :value,
            <% end %>
          }
        ).validate.must_be_truthy

        proc do
          instance_for(
            :instance_id => 'abc123',
            :scope => scope,
            :kind => kind,
            :data => {
              :bad_key => :wut
            }
          ).validate
        end.must_raise ActionController::ParameterMissing
      end
    ]
  end
end
