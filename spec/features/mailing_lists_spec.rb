require 'spec_helper'

describe "Mailing Lists" do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }

  let!(:contact) { FactoryGirl.create(:contact) }
  let!(:company) { FactoryGirl.create(:company) }

  describe "GET /mailing_lists" do
    it "gets all mailing lists" do
      MailingList.create!(name: "My List")
      visit mailing_lists_path
      expect(page.status_code).to be 200
      expect(page).to have_content "My List"
    end
  end

  describe "GET /mailing_lists/new" do
    it "adds a new mailing list" do
      john = Contact.create!(last_name: "Doe", email_infos: [ { value: "john@doe.com" } ])
      visit new_mailing_list_path
      fill_in "mailing_list_name", with: "Executive committee"
      select "Doe <john@doe.com>", from: "mailing_list_contact_ids"
      click_button "Create"
      expect(current_path).to eq(mailing_lists_path)
      expect(page).to have_content "Executive committee"
      expect(page).to have_content "john@doe.com"
    end
  end

  describe "GET /mailing_lists/:id/edit" do
    it "edits an existing mailing list" do
      john = Contact.create!(last_name: "Doe", email_infos: [ { value: "john@doe.com" } ])
      list = MailingList.create!(name: "Board", contact_ids: [ john.id ])
      visit edit_mailing_list_path(list)
      fill_in "mailing_list_name", with: "The board"
      unselect "Doe <john@doe.com>", from: "mailing_list_contact_ids"
      click_button "Apply modifications"
      expect(current_path).to eq(mailing_lists_path)
      expect(page).to have_content "The board"
      expect(page).not_to have_content "john@doe.com"
    end
  end

  describe "DELETE /mailing_lists/:id" do
    it "destroys the requested list" do
      john = Contact.create!(last_name: "Dupont", email_infos: [ { value: "john@dupont.com" } ])
      list = MailingList.create!(name: "Board", contact_ids: [ john.id ])
      visit mailing_lists_path
      click_link "Delete mailinglist #{list.to_param}"
      expect(current_path).to eq(mailing_lists_path)
      expect(page).to have_content "Mailing list was successfully destroyed"
      expect(page).not_to have_content "Board"
      expect(MailingList.count).to eq(0)
      expect(Contact.where(last_name: "Dupont").to_a.count).to eq(1)
    end
  end
end
