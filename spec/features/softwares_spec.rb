require 'spec_helper'

describe "Softwares" do
  let(:user) { FactoryGirl.create(:user) }
  let(:datacenter) { FactoryGirl.create(:datacenter) }
  let(:foreign_datacenter) { FactoryGirl.create(:datacenter, name: "Berlin") }

  before do
    login_as user
    @app = Software.create!(name: "app-01")
    Software.create!(name: "app-03")
    Software.create!(name: "app-02")
    SoftwareInstance.create!(name: "prod", authentication_method: "none", software_id: @app.id)
    Role.create(name: "Developer")
  end

  describe "GET /softwares" do
    it "gets all softwares ordered by name" do
      visit softwares_path
      expect(page.status_code).to be 200
      expect(page).to have_content "app-01"
    end

    it "only sees softwares in visible_datacenters or without datacenter" do
      user.update_attribute(:visible_datacenter_ids, [datacenter.id])
      Software.create!(name: "app-04", datacenter_ids: [foreign_datacenter.id])
      visit softwares_path
      expect(page.status_code).to be 200
      expect(page).to have_content "app-01"     #no datacenter
      expect(page).not_to have_content "app-04" #datacenter, not visible
    end
  end

  describe "GET /softwares/:id" do
    it "shows an software page" do
      visit software_path(@app)
      expect(page).to have_selector "h2", text: "app-01"
    end
  end

  describe "GET /softwares/:id/edit" do
    it "shows an software form" do
      visit edit_software_path(@app)
      expect(page).to have_selector "form#edit_software_#{@app.id}"
    end
  end
end
