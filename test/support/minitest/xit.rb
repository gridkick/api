module Minitest::Expectations
  def xit( name , &implementation )
    it name do
      skip
    end
  end
end
