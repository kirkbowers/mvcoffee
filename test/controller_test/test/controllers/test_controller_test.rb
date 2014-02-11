require 'test_helper'

class TestControllerTest < ActionController::TestCase
  test "should get default_timer" do
    get :default_timer
    assert_response :success
  end

  test "should get override_timer" do
    get :override_timer
    assert_response :success
  end

  test "should get no_timer" do
    get :no_timer
    assert_response :success
  end

  test "should get no_refresh" do
    get :no_refresh
    assert_response :success
  end

end
