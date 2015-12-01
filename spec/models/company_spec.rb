require 'spec_helper'

describe Company do
  it "has a name to be valid" do
    expect(Company.new).not_to be_valid
    expect(Company.new(name: "WorldCompany")).to be_valid
    expect(Company.new(name: "WorldCompany").image_url).to eq("building.png")
  end

  describe "#search" do
    before do
      @company1 = Company.create(name: "WorldCompany")
      @company2 = Company.create(name: "TinyCompany")
    end

    it "returns everything if parameter is blank" do
      expect(Company.like("").to_a).to match_array([@company1, @company2])
    end
    
    it "filters companys by name" do
      expect(Company.like("World").to_a).to match_array([@company1])
      expect(Company.like("Tiny").to_a).to match_array([@company2])
      expect(Company.like("Comp").to_a).to match_array([@company1, @company2])
    end
  end

  describe "scopes" do
    before do
      @company1 = Company.create(name: "WorldCompany", is_maintainer: false)
      @company2 = Company.create(name: "TinyCompany", is_maintainer: true)
    end

    it "returns maintainers only" do
      expect(Company.maintainers.to_a).to match_array([ @company2 ])
    end
  end

  describe "#maintained_servers" do
    before do
      @company = Company.create(name: "World 1st company", is_maintainer: true)
      @server1 = Server.create(name: "srv-01", maintainer_id: @company.id.to_s)
      @server2 = Server.create(name: "srv-02", maintainer_id: nil) 
    end

    it "has some maintained servers" do
      @company.reload
      expect(@company.maintained_servers.to_a).to eq([ @server1 ])
    end
  end
end
