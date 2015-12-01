require 'spec_helper'

describe Upgrade do
  let(:server) { FactoryGirl.create(:server) }
  let(:upgrade) { Upgrade.create!(server_id: server.id) }

  it "belongs to one server" do
    expect(upgrade.server).to eq server
    expect(server.reload.upgrade).to eq upgrade
  end

  it "has a server" do
    expect(Upgrade.new).not_to be_valid
    expect(Upgrade.new(server: FactoryGirl.create(:virtual))).to be_valid
  end

  it "delegates #to_s to server" do
    expect(Upgrade.new(server: FactoryGirl.create(:virtual, name: "server-37")).to_s).to eq("server-37")
  end

  it "stores #packages_list as a Hash" do
    obj = [ {"name" => "libc6"}, {"name" => "kernel"}]
    upgrade.packages_list = obj
    upgrade.save
    upgrade.reload
    expect(upgrade.packages_list).to eq obj
  end

  it "updates counts when updating packages list" do
    expect(upgrade.packages_list).to be_blank
    expect(upgrade.count_total).to eq 0
    upgrade.packages_list = [{"name"=>"kernel", "status"=>"important"}, {"name"=>"libX", "status"=>"normal"}]
    upgrade.save!
    upgrade.reload
    expect(upgrade.count_total).to eq 2
    expect(upgrade.count_normal).to eq 1
  end

  it "has an upgrader" do
    user = FactoryGirl.create(:user)
    upgrade.upgrader_id = user.id
    upgrade.save
    expect(upgrade.reload.upgrader).to eq user
  end
end
