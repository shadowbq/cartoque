require 'spec_helper'

describe "Databases" do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }

  let!(:database) { Database.create!(name: "db-01", type: "postgres") }

  describe "GET /databases" do
    it "gets all databases" do
      visit databases_path
      expect(page.status_code).to be 200
      expect(page).to have_content "db-01"
    end
  end

  describe "GET /databases/:id" do
    it "shows a database page" do
      visit database_path(database.to_param)
      expect(page).to have_selector "h1", text: /Databases.*db-01/
    end
  end

  describe "GET /databases/new & POST /databases" do
    before do
      FactoryGirl.create(:server)
    end

    it "creates a new database" do
      visit new_database_path
      expect(page.status_code).to eq(200)
      fill_in "database_name", with: "vm-oracle-01"
      select "oracle", from:  "database_type"
      select "", from: "database_server_ids"
      select "server-01", from: "database_server_ids"
      click_button "Create"
      expect(current_path).to eq(databases_path)
      expect(page).to have_content "vm-oracle-01"
      expect(page).to have_content "server-01"
    end
  end

  describe "GET /databases/:id/edit" do
    it "edits a database" do
      visit edit_database_path(database.to_param)
    end
  end

  describe "GET /databases/distribution" do
    it "shows a map of your databases" do
      visit distribution_databases_path
    end
  end
end
