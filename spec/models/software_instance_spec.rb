require 'spec_helper'

describe SoftwareInstance do
  it "has a name, an authentication method and a software" do
    instance = SoftwareInstance.new
    instance.should_not be_valid
    instance.errors.messages.keys.sort.should == [:software, :authentication_method, :name]
    instance.should have(4).errors
    instance.name = "prod"
    instance.software = FactoryGirl.create(:software)
    instance.authentication_method = "none"
    instance.should be_valid
  end
end
