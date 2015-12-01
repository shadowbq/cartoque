require 'spec_helper'

describe SoftwareInstance do
  it "has a name, an authentication method and a software" do
    instance = SoftwareInstance.new
    expect(instance).not_to be_valid
    expect(instance.errors.messages.keys.sort).to eq([:software, :authentication_method, :name])
    expect(instance.size).to eq(4)
    instance.name = "prod"
    instance.software = FactoryGirl.create(:software)
    instance.authentication_method = "none"
    expect(instance).to be_valid
  end
end
