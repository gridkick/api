require 'test_helper'

class StaticControllerTest < ActionController::TestCase
  it 'returns paths for root requests' do
    get :home
    assert{ response.success? }
  end
end

