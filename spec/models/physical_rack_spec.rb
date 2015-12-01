require 'spec_helper'

describe PhysicalRack do
  before do
    @rack = FactoryGirl.create(:rack1)
    @site = FactoryGirl.create(:room)
  end

  #TODO: move it to a presenter
  describe "#full_name" do
    it "formats correctly with #full_name or #to_s" do
      expect(@rack.to_s).to eq "Rack 1"
      expect(@site.to_s).to eq "Hosting Room 1"
      @rack.site = @site
      @rack.save
      expect(@rack.to_s).to eq "Hosting Room 1 - Rack 1"
    end
  end

  describe "#site_name" do
    it "is a denormalized version of #site.try(:name)" do
      expect(@rack.site_name).to be_blank

      @rack.update_attribute(:site_id, @site.id)
      expect(@rack.reload.site_name).to eq("Hosting Room 1")

      @site.reload.update_attribute(:name, "Room 1")
      expect(@rack.reload.site_name).to eq("Room 1")

      @site.destroy
      expect(@rack.reload.site_name).to be_blank
    end
  end

  describe "#stock?" do
    it "returns true only if rack is marked as stock" do
      expect(PhysicalRack.new(name: "stock", status: PhysicalRack::STATUS_STOCK).stock?).to be_truthy
    end
  end
end
