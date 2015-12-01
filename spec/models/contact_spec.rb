#encoding: utf-8
require 'spec_helper'

describe Contact do
  it "has a first name, a last name and an image url to be valid" do
    expect(Contact.new).not_to be_valid
    expect(Contact.new(last_name: "Doe", image_url: "")).not_to be_valid
    expect(Contact.new(last_name: "Doe", image_url: "ceo.png")).to be_valid
    expect(Contact.new(last_name: "Doe").image_url).to eq("ceo.png")
  end

  it "returns the full name of a person" do
    contact = Contact.new(first_name: "John", last_name: "Doe")
    expect(contact.full_name).to eq("John Doe")
  end

  it "returns a shortened version of the name of a person" do
    contact = Contact.new(first_name: "John-Mitchel Charles", last_name: "Doe")
    expect(contact.short_name).to eq("JMC Doe")
    contact.first_name = "Jérémy"
    expect(contact.short_name).to eq("J Doe")
    contact.first_name = "john"
    contact.last_name = "DOE"
    expect(contact.short_name).to eq("J Doe")
  end

  it "shortens long email addresses" do
    c = Contact.create!(last_name: "Doe")
    c.email_infos << EmailInfo.create(value: "john.doe@example.com")
    expect(c.reload.short_email).to eq("john.doe@example.com")
    c.contact_infos.first.destroy
    c.email_infos << EmailInfo.create(value: "john.doe@very.long-subdomain.example.com")
    expect(c.reload.short_email).to eq("john.doe@...example.com")
  end

  it "destroys the associated contact infos when deleted" do
    c = Contact.create(first_name: "John", last_name: "Doe")
    expect(c).to be_persisted
    expect(c).to have(0).contact_infos
    c.email_infos << EmailInfo.create(value: "blah@example.com")
    c.email_infos << EmailInfo.create(value: "555-123456")
    expect(c.reload).to have(2).contact_infos
  end

  describe "#available_images and #available_images_index" do
    it "is an array of available images" do
      expect(Contact.available_images).to be_a(Array)
    end

    it "generates a hash" do
      hsh = Contact.available_images_hash
      images = Contact.available_images
      expect(hsh).to be_a(Hash)
      expect(hsh.length).to eq images.length
      expect(hsh.keys.sort).to eq images.sort
      expect(hsh.values.sort).to eq images.sort
    end
  end

  describe "#search" do
    before do
      @contact1 = Contact.create(first_name: "John", last_name: "Doe", job_position: "Commercial")
      @contact2 = Contact.create(first_name: "James", last_name: "Dean", job_position: "Director")
    end

    it "returns everything if parameter is blank" do
      expect(Contact.like("").to_a).to match_array([@contact1, @contact2])
    end

    it "filters contacts by first_name, last_name, and job_position" do
      expect(Contact.like("James").to_a).to match_array([@contact2])
      expect(Contact.like("Doe").to_a).to match_array([@contact1])
      expect(Contact.like("D").to_a).to match_array([@contact1, @contact2])
      expect(Contact.like("Director").to_a).to match_array([@contact2])
    end
  end

  describe "#emailable" do
    it "returns only people/companies with some email_infos" do
      c1 = Contact.create(last_name: "Doe", email_infos: [ EmailInfo.new(value: "a@b.com") ])
      c2 = Contact.create(last_name: "Grinch")
      expect(Contact.emailable).to eq([ c1 ])
    end
  end

  #TODO: move it to a dedicated spec on Contactable module
  describe "#with_internals scope" do
    it "retrieve internal users only if param is truthy" do
      bob = Contact.create!(last_name: "Smith", internal: true)
      alice = Contact.create!(last_name: "Smith", internal: false)
      expect(Contact.all).to include bob
      expect(Contact.all).to include alice
      expect(Contact.with_internals(false).to_a).not_to include bob
      expect(Contact.with_internals(false).to_a).to include alice
      #but
      expect(Contact.with_internals(true).to_a).to include bob
      expect(Contact.with_internals(true).to_a).to include alice
    end
  end

  describe "#company_name=" do
    it "auto-creates a company if none with that name already exists" do
      company = Company.create(name: "World Company")
      expect { Contact.create(last_name: "Smith", company_name: "World Company") }.not_to change(Company, :count)
      expect(Company.where(name: "Universe Company").count).to eq 0
      expect { Contact.create(last_name: "Parker", company_name: "Universe Company") }.to change(Company, :count).by(+1)
      expect(Company.where(name: "Universe Company").count).to eq 1
    end

    it "propagates #internal value when auto-creating a company" do
      company = Company.create(name: "World Company")
      Contact.create(last_name: "Smith", company_name: "World Company", internal: true)
      expect(company.reload.internal).to be_falsey
      Contact.create(last_name: "Parker", company_name: "Universe Company", internal: false)
      expect(Company.where(name: "Universe Company").first.internal).to be_falsey
      #but
      #WARNING: it only works if internal field is set before company_name, which is the case in the HTML form
      #TODO: fix it :)
      Contact.create(last_name: "Goldberg", internal: true, company_name: "Our team")
      expect(Company.where(name: "Our team").first.internal).to be_truthy
    end
  end
end
