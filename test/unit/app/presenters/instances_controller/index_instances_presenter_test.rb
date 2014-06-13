require 'test_helper'

class InstancesController
  class IndexInstancesPresenterTest < ActiveSupport::TestCase
    describe 'class functionality' do
      it 'knows what foreign instance data keys are allowed' do
        klass::ALLOWED_FOREIGN_INSTANCE_DATA_KEYS.must_equal %w(
          host
          port
          username
          password
        )
      end

      it 'has a factory method to immediately present' do
        assert { klass.present [] }
      end
    end

    describe 'instance functionality' do
      it 'accepts instances on initialization' do
        proc do
          klass.new
        end.must_raise ArgumentError

        assert do
          klass.new []
        end
      end

      it 'outputs host data' do
        presenter = instance
        i = presenter.instances.first
        host_output = presenter.host_for i
        host_output.must_equal i.foreign_instance_data[ 'host' ]
        i.foreign_instance_data.delete 'host'
        presenter.host_for( i ).must_match /unknown/i
      end

      it 'outputs port data' do
        presenter = instance
        i = presenter.instances.first
        port_output = presenter.port_for i
        port_output.must_equal i.foreign_instance_data[ 'port' ]
        i.foreign_instance_data.delete 'port'
        presenter.port_for( i ).must_match /unknown/i
      end

      it 'outputs service data' do
        presenter = instance
        i = presenter.instances.first
        service_slug_output = presenter.service_slug_for i
        service_slug_output.must_equal i.service_slug
        presenter.service_slug_for( Map.new :service_slug => false ).must_match /unknown/i
      end

      it 'outputs state data' do
        presenter = instance
        i = presenter.instances.first
        state_output = presenter.state_for i
        state_output.must_equal i.state
        presenter.state_for( Map.new :state => false ).must_match /unknown/i
      end

      it 'outputs ID data' do
        presenter = instance
        i = presenter.instances.first
        id_output = presenter.id_for i
        id_output.must_equal i.id
        presenter.id_for( Map.new :id => false ).must_match /unknown/i
      end

      it 'has an empty message for no instances' do
        instance.empty_instance_output.wont_be_empty
      end

      it 'returns empty message for empty instances collection' do
        i = klass.new []
        i.present.must_equal i.empty_instance_output
      end

      it 'presents instance even if foreign_instance_data is empty' do
        i =
          Instance.new \
            :state => :running,
            :user => User.new,
            :service_slug => :redis

        i2 = klass.new [ i ]
        assert( 'no NilClass error on top-level method' ){ i2.present }
        assert( 'no NilClass error on specific method' ){ i2.connection_data_for i }
      end

      it 'outputs data for empty connection data' do
        i =
          Instance.new \
            :state => :running,
            :user => User.new,
            :service_slug => :redis

        i2 = klass.new [ i ]
        i2.empty_connection_data_for( i ).must_be_a String
      end

      def instance
        i =
          Instance.new \
            :state => :running,
            :user => User.new,
            :service_slug => :redis,
            :foreign_instance_data => {
              'host' => 'localhost',
              'port' => '1234'
            }

        klass.new [ i ]
      end
    end

    def klass
      InstancesController::IndexInstancesPresenter
    end
  end
end
