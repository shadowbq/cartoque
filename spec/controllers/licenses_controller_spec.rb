require 'spec_helper'

describe LicensesController do
  login_user

  before do
    @license = License.create(editor: "WorldSoft")
  end

  it "gets index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:licenses)
  end

  it "creates license" do
    expect{ post :create, license: { editor: "WorldSoft", key: "123456" } }.to change(License, :count)
    assert_redirected_to licenses_path
  end

  it "gets edit" do
    get :edit, id: @license.to_param
    assert_response :success
  end

  it "updates license" do
    put :update, id: @license.to_param, license: @license.attributes
    assert_redirected_to licenses_path
  end

  it "destroys license" do
    expect{ delete :destroy, id: @license.to_param }.to change(License, :count).by(-1)
    assert_redirected_to licenses_path
  end
end
