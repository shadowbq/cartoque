require 'spec_helper'

describe "Licenses" do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }

  let!(:license) { License.create!(editor: "Big company") }

  describe "GET /licenses" do
    it "gets all licenses" do
      visit licenses_path
      expect(page.status_code).to be 200
      expect(page).to have_content "Big company"
    end
  end

  describe "GET /licenses/:id/edit" do
    it "edits a license" do
      visit edit_license_path(license)
    end
  end
end
