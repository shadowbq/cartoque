require 'spec_helper'

describe UsersController do
  login_user

  before do
    @user = FactoryGirl.create(:bob)
  end

  it "gets index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  it "gets new" do
    get :new
    assert_response :success
  end

  it "creates user" do
    expect{ post :create, user: {"name"=>"john"} }.to change(User, :count)
    assert_redirected_to users_path
  end

  it "gets edit" do
    get :edit, id: @user.to_param
    assert_response :success
  end

  it "updates user" do
    put :update, id: @user.to_param, user: @user.attributes
    assert_redirected_to users_path
  end

  it "destroys user" do
    expect{ delete :destroy, id: @user.to_param }.to change(User, :count).by(-1)
    assert_redirected_to users_path
  end
end
