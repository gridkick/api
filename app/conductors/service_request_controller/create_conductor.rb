require_dependency 'service_requests_controller' unless defined? ServiceRequestsController

class ServiceRequestsController
  class CreateConductor
    include App::Conductors::Create

    attr_reader :service_request

    def create
      @service_request =
        ServiceRequest.new \
          :instance     => Instance.find( params.fetch( :instance_id ) ),
          :user         => user,
          :scope        => params.fetch( :scope , default_scope ),
          :kind         => params.fetch( :kind , default_kind ),
          :request_data => params.fetch( :data , Hash.new )
    end

    def default_kind
      'unknown_kind'
    end

    def default_scope
      'unknown_scope'
    end

    def save
      service_request.queue
    end
  end
end
