require 'spec_helper'

describe "Softwares API" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:software) { Software.create!(name: "app-01") }
  let!(:app_instance) { SoftwareInstance.create!(name: "prod", software: software, authentication_method: "none") }

  before { page.set_headers("HTTP_X_API_TOKEN" => user.authentication_token) }
  after { page.set_headers("HTTP_X_API_TOKEN" => nil) }

  describe "GET /softwares.json" do
    it "gets all softwares" do
      visit softwares_path(format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body) rescue nil
      expect(res).not_to be nil
      expect(res.keys).to eq(["softwares"])
      expect(res["softwares"].size).to eq(1)
      app = res["softwares"].first
      expect(app["name"]).to eq("app-01")
      expect(app.keys).not_to include "software_instances"
      expect(app["created_at"]).to be_present
      expect(app["updated_at"]).to be_present
    end
  end

  describe "GET /softwares/:id.json" do
    it "shows a specific software" do
      visit software_path(id: software.id.to_s, format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body) rescue nil
      expect(res).not_to be nil
      expect(res.keys).to eq(["software"])
      app = res["software"]
      expect(app["name"]).to eq("app-01")
      #app.keys.should_not include "software_instances"
      expect(app["created_at"]).to be_present
      expect(app["updated_at"]).to be_present
    end
  end
end
