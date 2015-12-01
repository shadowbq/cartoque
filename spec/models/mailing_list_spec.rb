require 'spec_helper'

describe MailingList do
  let(:ml) { MailingList.create(name: "My list") }
  let(:contact) { Contact.create(last_name: "Doe", email_infos: [ EmailInfo.new(value: "john@doe.com") ]) }
  let (:company) { Company.create(name: "World Company", email_infos: [ EmailInfo.new(value: "world@company.com") ]) }

  it "updates contact and company ids" do
    expect(ml.contact_ids).to eq([])
    expect(ml.company_ids).to eq([])
    ml.update_attributes(contact_ids: [contact.id.to_s], company_ids: [company.id.to_s])
    ml.reload
    expect(ml.contact_ids).to include contact.id
    expect(ml.contacts).to include contact
    expect(ml.company_ids).to include company.id
    expect(ml.companies).to include company
  end

  it "groups contactable objects" do
    expect(ml.contactables).to eq([])
    ml.update_attributes(contact_ids: [contact.id.to_s], company_ids: [company.id.to_s])
    ml.reload
    expect(ml.contactables).to match_array([contact, company])
  end

  it "gives access to mail addresses directly" do
    ml.update_attributes(contact_ids: [contact.id.to_s], company_ids: [company.id.to_s])
    ml.reload
    expect(ml.email_addresses).to match_array(%w(john@doe.com world@company.com))
  end

  describe "#email_addresses" do
    it "fails silently if an user no more has email address" do
      ml.update_attributes(contact_ids: [contact.id.to_s], company_ids: [company.id.to_s])
      contact.email_infos.first.destroy
      ml.reload
      expect(ml.email_addresses).to eq(%w(world@company.com))
    end
  end
end
