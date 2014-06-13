module MiniTest
  class Unit
    class TestCase
      def assert_truthy( _ , val )
        assert !!val
      end
    end
  end
end

module Minitest::Expectations
  infect_an_assertion \
    :assert_truthy,
    :must_be_truthy
end
