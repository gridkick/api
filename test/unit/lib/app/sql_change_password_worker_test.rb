require 'test_helper'

describe App::SqlChangePasswordWorker do 
  
  def new_worker
    i = Instance.new
    klass.new i
  end
  
  def klass
    @_k1 ||= Class.new do 
      include App::SqlChangePasswordWorker
      
      def initialize( instance )
        @instance = instance
      end
      
      def instance_id
        @instance.id.to_s
      end
    end
    
  end
end
