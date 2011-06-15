require 'test_helper'

class SaasControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, :id => :redmine
    assert_response :success
  end

end