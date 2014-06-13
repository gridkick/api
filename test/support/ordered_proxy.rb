class OrderedProxy
  attr_reader :tests

  def initialize( tests = [] )
    @tests = tests
  end

  def it( name , &test )
    @tests << [ name , test ]
  end

  def name
    tests.map do | test |
      test[ 0 ]
    end.join( ' // AND // ' )
  end

  def test_blocks
    tests.map do | test |
      test[ 1 ]
    end
  end
end

class ActiveSupport::TestCase
  def self.ordered
    proxy = OrderedProxy.new
    yield proxy if block_given?
    it proxy.name do
      proxy.test_blocks.each do | t |
        instance_eval &t
      end
    end
  end
end
