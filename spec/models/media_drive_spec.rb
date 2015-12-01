require 'spec_helper'

describe MediaDrive do
  it "is valid with just a name" do
    expect(MediaDrive.new).not_to be_valid
    expect(MediaDrive.new(name: "DVD")).to be_valid
  end
end
