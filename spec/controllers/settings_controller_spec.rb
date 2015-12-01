require 'spec_helper'

describe SettingsController do
  render_views
  login_user

  it "GET /settings" do
    get :index
    assert_response :success
  end

  it "PUT /settings/update_all" do
    put :update_all, settings: { "site_announcement_message" => "Site in maintenance mode" }
    assert_redirected_to settings_path
    assert_equal "Site in maintenance mode", Setting.site_announcement_message

    put :update_all, settings: { "site_announcement_message" => "" }
    assert_redirected_to settings_path
    assert_equal "", Setting.site_announcement_message
  end

  it "GET /settings/edit_visibility" do
    get :edit_visibility, back_url: 'blah', format: 'js'
    expect(response).to be_success
    expect(response.body).to include "Change visible datacenters"
    expect(response.body).to include "/settings/update_visibility?back_url=blah"
  end

  describe "PUT /settings/update_visibility" do
    it "resets visible datacenters without parameters" do
      put :update_visibility, back_url: '/settings'
      expect(response).to redirect_to '/settings'
      expect(@user.reload.visible_datacenters).to be_empty
    end

    it "sets visible datacenters for current user" do
      datacenter = FactoryGirl.create(:datacenter)
      put :update_visibility, back_url: '/settings', visible_datacenter_ids: [datacenter.id.to_s]
      expect(response).to redirect_to '/settings'
      expect(@user.reload.visible_datacenters).to eq([datacenter])
    end
  end
end
