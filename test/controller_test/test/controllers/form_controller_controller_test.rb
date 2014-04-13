require 'test_helper'

class FormControllerControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get other" do
    get :other
    assert_response :success
  end

  test "should get post_button" do
    get :post_button
    assert_response :success
  end

  test "should get post_form" do
    get :post_form
    assert_response :success
  end

  test "should get delete" do
    get :delete
    assert_response :success
  end

end
