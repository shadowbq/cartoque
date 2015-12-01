require 'spec_helper'

describe ContactDecorator do
  let(:contact) { FactoryGirl.create(:contact).decorate }

  it "gives a short form with just last name and first name" do
    expect(contact.short_form).to eq("Doe, John")

    contact.update_attribute(:first_name, nil)
    contact.reload
    expect(contact.short_form).to eq("Doe")
  end

  it "return a long form with last name, first name and company" do
    expect(contact.long_form).to eq("Doe, John (WorldCompany)")

    contact.update_attribute(:company_id, nil)
    contact.reload
    expect(contact.long_form).to eq("Doe, John")
    expect(contact.long_form).to eq(contact.short_form)

    contact.update_attribute(:first_name, nil)
    contact.reload
    expect(contact.long_form).to eq("Doe")
  end

  it "return a clean form for mailing lists" do
    expect(contact.mailing_list_form).to eq("Doe, John (WorldCompany) &lt;&gt;")
    EmailInfo.create(value: "jdoe@example.net", entity: contact)
    contact.reload
    expect(contact.mailing_list_form).to eq("Doe, John (WorldCompany) &lt;jdoe@example.net&gt;")
  end

  describe "#to_html" do
    it "gives an html version of the contact" do
      expect(contact.to_html).to have_selector("a", text: "Doe, John") 
    end

    it "accepts a parameter to format the contact name" do
      expect(contact.to_html(:long_form)).to have_selector("a", text: "Doe, John (WorldCompany)")
    end
  end
end
