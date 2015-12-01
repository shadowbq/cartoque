require 'spec_helper'

describe Storage do
  it "is valid with just a constructor and a server" do
    storage = Storage.new
    expect(storage).not_to be_valid
    expect(storage).to have(2).errors
    storage.server = FactoryGirl.create(:server)
    storage.constructor = "IBM"
    expect(storage).to be_valid
  end
end
