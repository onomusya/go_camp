require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get rules" do
    get pages_rules_url
    assert_response :success
  end
end
