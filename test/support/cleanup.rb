module Cleanup
  extend self

  def remove_model( klass )
    if klass.count > 0
      warn "Instances are being created of type #{ klass.name } during test runs!"
    end
    klass.destroy_all
  end

  def remove_models
    [
      Instance,
      ServiceRequest,
      User
    ].each do | klass |
      remove_model klass
    end
  end

  def run!
    remove_models
  end
end

Cleanup.run!
