require 'spec_helper'

describe "Servers API" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:server) { Server.create!(name: "srv-01") }
  let(:server_with_os) { os = OperatingSystem.create(name: "Debian"); Server.create!(name: "srv-debian", operating_system: os) }
  let(:software) { Software.create!(name: "app-01") }
  let(:app_instance) { SoftwareInstance.create!(name: "prod", software: software) }

  before { page.set_headers("HTTP_X_API_TOKEN" => user.authentication_token) }
  after { page.set_headers("HTTP_X_API_TOKEN" => nil) }

  describe "GET /servers.json" do
    it "gets all servers" do
      visit servers_path(format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body) rescue nil
      expect(res).not_to be nil
      expect(res.keys).to eq(["servers"])
      expect(res["servers"].size).to eq(1)
      srv = res["servers"].first
      expect(srv["name"]).to eq("srv-01")
      expect(srv["created_at"]).to be_present
      expect(srv["updated_at"]).to be_present
    end
  end

  describe "GET /servers/:id" do
    it "shows a specific server" do
      visit server_path(id: server.id.to_s, format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body) rescue nil
      expect(res).not_to be nil
      expect(res.keys).to eq(["server"])
      srv = res["server"]
      expect(srv["name"]).to eq("srv-01")
      expect(srv["created_at"]).to be_present
      expect(srv["updated_at"]).to be_present
    end

    it "includes the operating system with the server" do
      visit server_path(id: server_with_os.id.to_s, format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body)
      srv = res["server"]
      expect(srv["operating_system"]["name"]).to eq("Debian")
    end
  end
end
