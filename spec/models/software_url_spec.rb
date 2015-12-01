require 'spec_helper'

describe SoftwareUrl do
  before do
    @app = Software.create(name: "app-01")
    @inst = SoftwareInstance.new(name: "prod", software: @app)
  end

  it "shouldn't be valid if not in an SoftwareInstance" do
    expect(SoftwareUrl.new(url: "http://www.example.com/")).not_to be_valid
    expect(SoftwareUrl.new(url: "http://www.example.com/", software_instance: @inst)).to be_valid
  end

  it "shouldn't create an empty url" do
    expect(SoftwareUrl.new(url: "", software_instance: @inst)).not_to be_valid
  end
end
