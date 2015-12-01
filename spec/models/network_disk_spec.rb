require 'spec_helper'

describe NetworkDisk do
  it "has a server and a client" do
    netdisk = NetworkDisk.new
    expect(netdisk).not_to be_valid
    expect(netdisk).to have(2).errors
    expect(netdisk.errors.keys.sort).to eq [:client, :server]
    netdisk.client = FactoryGirl.create(:virtual)
    netdisk.server = FactoryGirl.create(:server)
    expect(netdisk).to be_valid
  end
end
