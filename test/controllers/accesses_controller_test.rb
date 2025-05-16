require "test_helper"

class AccessesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get accesses_show_url
    assert_response :success
  end
end
