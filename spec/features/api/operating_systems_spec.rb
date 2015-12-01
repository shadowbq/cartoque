require 'spec_helper'

describe "Operating Systems API" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:system) { OperatingSystem.create!(name: "Debian") }

  before { page.set_headers("HTTP_X_API_TOKEN" => user.authentication_token) }
  after { page.set_headers("HTTP_X_API_TOKEN" => nil) }

  describe "GET /operating_systems.json" do
    it "gets all operating_systems" do
      visit operating_systems_path(format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body) rescue nil
      expect(res).not_to be nil
      expect(res.keys).to eq(["operating_systems"])
      expect(res["operating_systems"].size).to eq(1)
      sys = res["operating_systems"].first
      expect(sys["name"]).to eq("Debian")
    end
  end

  describe "GET /operating_systems/:id" do
    it "shows a specific operating_system" do
      visit operating_system_path(id: system.id.to_s, format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body) rescue nil
      expect(res).not_to be nil
      expect(res.keys).to eq(["operating_system"])
      sys = res["operating_system"]
      expect(sys["name"]).to eq("Debian")
    end
  end
end
