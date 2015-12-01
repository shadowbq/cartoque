require 'spec_helper'

describe Datacenter do
  it "has a name" do
    expect(Datacenter.new).not_to be_valid
    expect(Datacenter.new(name: "Blah")).to be_valid
  end

  it "has a unique name across the instance" do
    Datacenter.create!(name: "Datacenter")
    dc = Datacenter.new(name: "Datacenter")
    expect(dc).not_to be_valid
    expect(dc.errors.keys).to eq([:name])
  end

  describe ".default" do
    before do
      Datacenter.default = nil
    end

    it "returns first datacenter if any" do
      expect(Datacenter.count).to eq(0)
      Datacenter.create!(name: "Hosterz")
      expect(Datacenter.default.name).to eq("Hosterz")
    end

    it "generates a default datacenter if none" do
      expect(Datacenter.count).to eq(0)
      dc = Datacenter.default
      expect(dc).not_to be_blank
      expect(dc.name).to eq("Datacenter")
    end

    it "allows changing default datacenter in controller" do
      Datacenter.create!(name: "Hosterz")
      expect(Datacenter.default.name).to eq("Hosterz")
      Datacenter.default = Datacenter.create(name: "Phoenix")
      expect(Datacenter.default.name).to eq("Phoenix")
    end
  end
end
