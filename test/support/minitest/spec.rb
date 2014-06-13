module Minitest::Expectations
  infect_an_assertion :assert_kind_of, :must_be_a
  infect_an_assertion :assert_kind_of, :must_be_an
end
