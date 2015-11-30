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
      page.status_code.should == 200
      res = JSON.parse(page.body) rescue nil
      res.should_not be nil
      res.keys.should == ["softwares"]
      res["softwares"].should have(1).software
      app = res["softwares"].first
      app["name"].should == "app-01"
      app.keys.should_not include "software_instances"
      app["created_at"].should be_present
      app["updated_at"].should be_present
    end
  end

  describe "GET /softwares/:id.json" do
    it "shows a specific software" do
      visit software_path(id: software.id.to_s, format: "json")
      page.status_code.should == 200
      res = JSON.parse(page.body) rescue nil
      res.should_not be nil
      res.keys.should == ["software"]
      app = res["software"]
      app["name"].should == "app-01"
      #app.keys.should_not include "software_instances"
      app["created_at"].should be_present
      app["updated_at"].should be_present
    end
  end
end
