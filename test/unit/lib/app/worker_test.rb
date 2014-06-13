require 'test_helper'

class App::WorkerTest < ActiveSupport::TestCase
  describe 'class level functionality' do
    it 'inherits from Sidekiq::Worker' do
      klass.ancestors.must_include Sidekiq::Worker
    end

    describe 'perform' do
      # FIXME
      it 'needs to be written' do
        skip
      end
    end

    describe 'run' do
      # FIXME
      it 'needs to be written' do
        skip
      end
    end
  end

  def klass
    Class.new { include App::Worker }
  end
end
