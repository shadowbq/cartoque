require 'spec_helper'

describe "Databases API" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:database) { Database.create!(name: "db-01", type: "postgres") }
  let!(:instance1) { DatabaseInstance.create!(name: "pg-cluster-01", database: database, databases: {"foo"=>123}) }
  let!(:instance2) { DatabaseInstance.create!(name: "pg-cluster-empty", database: database) }

  before { page.set_headers("HTTP_X_API_TOKEN" => user.authentication_token) }
  after { page.set_headers("HTTP_X_API_TOKEN" => nil) }

  describe "GET /databases.json" do
    it "gets all databases" do
      visit databases_path(format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body) rescue nil
      expect(res).not_to be nil
      expect(res.keys).to eq(["databases"])
      expect(res["databases"].size).to eq(1)
      db = res["databases"].first
      expect(db["name"]).to eq("db-01")
      expect(db["instances"].count).to eq(1)
      expect(db["instances"].first["name"]).to eq("pg-cluster-01")
      expect(db["created_at"]).to be_present
      expect(db["updated_at"]).to be_present
    end
  end

  describe "GET /databases/:id" do
    it "shows a specific database" do
      visit database_path(id: database.id.to_s, format: "json")
      expect(page.status_code).to eq(200)
      res = JSON.parse(page.body) rescue nil
      expect(res).not_to be nil
      expect(res.keys).to eq(["database"])
      db = res["database"]
      expect(db["name"]).to eq("db-01")
      expect(db["created_at"]).to be_present
      expect(db["updated_at"]).to be_present
    end
  end
end
