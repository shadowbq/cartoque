require 'spec_helper'

describe SoftwareUrl do
  before do
    @app = Software.create(name: "app-01")
    @inst = SoftwareInstance.new(name: "prod", software: @app)
  end

  it "shouldn't be valid if not in an SoftwareInstance" do
    SoftwareUrl.new(url: "http://www.example.com/").should_not be_valid
    SoftwareUrl.new(url: "http://www.example.com/", software_instance: @inst).should be_valid
  end

  it "shouldn't create an empty url" do
    SoftwareUrl.new(url: "", software_instance: @inst).should_not be_valid
  end
end
