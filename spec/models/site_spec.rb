require 'spec_helper'

describe Site do
  it "is valid with just a name" do
    site = Site.new
    expect(site).not_to be_valid
    site.name = "room-1"
    expect(site).to be_valid
  end

  it "can have one or many racks" do
    site = Site.create(name: "room-1")
    rack = FactoryGirl.create(:rack1)
    rack.site = site
    rack.save
    expect(rack.site).to eq site
    expect(site.physical_racks.to_a).to eq [ rack ]
  end

  it "updates rack's site_name" do
    site = Site.create!(name: "room-1")
    rack = PhysicalRack.create!(name: "rack-one", site: site)
    srv =  Server.create!(name: "srv", physical_rack: rack)
    expect(rack.site_name).to eq("room-1")
    rack.reload

    site.name = "room-one"
    site.save
    expect(rack.reload.site_name).to eq("room-one")
    expect(srv.reload.physical_rack_full_name).to eq("room-one - rack-one")

    site.destroy
    expect(rack.reload.site_name).to eq(nil)
    expect(srv.reload.physical_rack_full_name).to eq("rack-one")
  end
end
