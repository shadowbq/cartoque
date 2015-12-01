require 'spec_helper'

describe ContactsHelper do
  describe "#full_position" do
    it "returns the full job position of a person" do
      person = FactoryGirl.create(:contact)
      expect(full_position(person)).to eq "CEO, WorldCompany"
      person.company = nil
      expect(full_position(person)).to eq "CEO"
      person.company = Company.new(name: "Blah Inc.")
      person.job_position = ""
      expect(full_position(person)).to eq "Blah Inc."
    end

    it "returns a linkified version of the company" do
      person = FactoryGirl.create(:contact)
      expect(full_position(person, true)).to match %r(CEO, <a href=".*">WorldCompany</a>)
      person.company = nil
      expect(full_position(person, true)).to eq "CEO"
      person.company = Company.new(name: "Blah Inc.")
      person.job_position = ""
      expect(full_position(person, true)).to match %r(^<a href=".*">Blah Inc.</a>)
    end
  end
end
