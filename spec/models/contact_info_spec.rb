require 'spec_helper'

describe ContactInfo do
  let(:contact) { FactoryGirl.create(:contact) }

  it "has all fields to be valid" do
    info = EmailInfo.new
    expect(info).not_to be_valid
    expect(info).to have_exactly(2).errors
    info.entity = FactoryGirl.create(:contact)
    info.value = "555-123456"
    expect(info).to be_valid
  end

  it "displays value when using #to_s" do
    expect(EmailInfo.new(value: "blah").to_s).to eq "blah"
  end
end
