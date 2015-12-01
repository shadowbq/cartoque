require 'spec_helper'

describe OperatingSystem do
  it "is valid with just a name" do
    system = OperatingSystem.new
    expect(system).not_to be_valid
    system.name = "Linux"
    expect(system).to be_valid
  end
end
