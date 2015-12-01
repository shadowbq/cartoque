require 'spec_helper'

describe "Storages" do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }

  let!(:server) { FactoryGirl.create(:server) }
  let!(:storage) { Storage.create! valid_attributes }

  def valid_attributes
    { constructor: "IBM", server: server }
  end

  describe "GET /storages" do
    it "list all storages" do
      visit storages_path
      expect(page.status_code).to eq(200)
      expect(page).to have_content "server-01"
      expect(page).to have_content "IBM"
    end
  end

  describe "GET /storages/new & POST /storages" do
    it "creates a new storage with valid attributes" do
      visit new_storage_path
      expect(page.status_code).to eq(200)
###      fill_in "storage_name", with: "Developer"
###      click_button "Create"
###      current_path.should == storages_path
###      page.should have_content "Developer"
    end
  end

  describe "GET /storages/:id/edit & PUT /storages/:id" do
    it "edits a storage with valid attributes" do
      visit edit_storage_path(storage.id)
      expect(page.status_code).to eq(200)
###      fill_in "storage_name", with: "Senior Expert"
###      click_button "Apply modifications"
###      current_path.should == storages_path
###      page.should have_content "Senior Expert"
    end
  end

  describe "DELETE /storages/:id" do
    it "destroys the requested storage" do
      expect(Storage.count).to eq(1)
      visit storages_path
      click_link "Delete storage #{storage.to_param}"
      expect(current_path).to eq(storages_path)
      expect(page).to have_content "Storage was successfully destroyed"
      expect(Storage.count).to eq(0)
    end
  end
end
