require 'test_helper'

class App::ProviderTest < ActiveSupport::TestCase
  describe 'class functionality' do
    describe 'create' do
      it 'can be created' do
        klass.must_respond_to :create
      end

      it 'takes an instance' do
        proc { klass.create }.must_raise ArgumentError
        proc { klass.create Class.new.new }.must_raise ArgumentError
        instance = Instance.new
        klass.any_instance.expects( :create ).returns true
        provider = assert( 'with an instance' ){ klass.create instance }
        assert( 'caches the instance' ){ klass.new( instance ).instance == instance }
      end

      it 'can save a custom create execution block' do
        klass.on_create_block.must_equal nil
        p = proc { true }
        klass.on_create &p
        assert_equal p , klass.on_create_block
      end
    end
  end

  describe 'instance functionality' do
    it 'memoizes a default create block' do
      i = klass_instance
      i.must_respond_to :default_on_create_block
      assert_equal i.default_on_create_block , i.default_on_create_block
    end

    it 'calculates the image name' do
      i = Instance.new :service_slug => :slug
      p = klass.new i
      p.expects( :image_version ).returns 1
      p.image_name.must_equal 'adv-proto-slug-snapshot-1'
    end

    it 'has a default port that errors if not overridden' do
      i = Instance.new :service_slug => :slug
      p = klass.new i
      p.must_respond_to :port
      proc { p.port }.must_raise NotImplementedError
    end

    xit 'fails the instance if an error occurs' do
      # TODO passing but meaningless
      # reason - different proc instances are used during each evaluation
      #     <Proc:0x007ffc41d5c330@/Users/weston/ventureio/api/test/unit/lib/app/provider_test.rb:52>
      #     <Proc:0x007ffc41d5c330@/Users/weston/ventureio/api/test/unit/lib/app/provider_test.rb:52>
      #     <Proc:0x007ffc41d654f8@/Users/weston/ventureio/api/lib/app/provider.rb:60>

      i = Instance.new
      i.expects( :fail_instance ).returns true
      blk = Proc.new {}
      # blk.expects( :instance_exec ).raises RuntimeError
      klass.on_create &blk
      p = klass.new i
      p.create #.must_equal false
    end

    it 'has some default foreign instance data' do
      i = klass.new Instance.new
      i.must_respond_to :default_foreign_instance_data
      i.default_foreign_instance_data.must_be_a Array
    end
  end

  def klass_instance
    klass.new Instance.new
  end

  def klass
    @_k1 ||= Class.new { include App::Provider }
  end

  def klass_with_create_implementation
    @_k2 ||=
      Class.new do
        include App::Provider
        def create
          true
        end
      end
  end
end
