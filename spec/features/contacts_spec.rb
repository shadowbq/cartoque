require 'spec_helper'

describe "Contacts, Companies" do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }

  let!(:contact) { FactoryGirl.create(:contact) }
  let!(:company) { FactoryGirl.create(:company) }

  describe "GET /contacts" do
    it "gets all contacts and companies" do
      visit contacts_path
      expect(page.status_code).to be 200
      expect(page).to have_content "John Doe"
      expect(page).to have_content "WorldCompany"
    end
  end

  describe "GET /contacts/:id" do
    it "displays contact informations" do
      visit contact_path(contact)
      expect(page).to have_content "John Doe"
    end
  end

  describe "GET /contacts/new" do
    it "adds a new contact" do
      visit new_contact_path
      expect(page).to have_selector "h1", text: "New contact"
      within("#new_contact") do
        fill_in 'contact_last_name',  with: 'Charles'
        fill_in 'contact_first_name', with: 'Wagner'
      end
      click_button 'Create'
      expect(page).to have_content 'Wagner Charles'
    end
  end

  describe "GET /contacts/:id/edit" do
    it "edits a contact" do
      visit edit_contact_path(contact)
      expect(page).to have_selector "h1", text: "Edit a contact"
      within("#edit_contact_#{contact.to_param}") do
        fill_in 'contact_last_name',  with: 'Charles'
        fill_in 'contact_first_name', with: 'Wagner'
      end
      click_button 'Apply modifications'
      expect(current_path).to eq(contact_path(contact))
      within "h1" do
        click_link 'Contacts'
      end
      expect(page).to have_selector "a[href='#{contact_path(contact)}']", text: "Wagner Charles"
    end
  end

  describe "GET /companies/new" do
    it "adds a new company" do
      visit new_company_path
      expect(page).to have_selector "h1", text: "New company"
      within("#new_company") do
        fill_in 'company_name',  with: 'Tiny Company'
      end
      click_button 'Create'
      expect(page).to have_content 'Tiny Company'
      within "h1" do
        click_link 'Contacts'
      end
      expect(page).to have_selector "a", text: "Tiny Company"
    end
  end
end
