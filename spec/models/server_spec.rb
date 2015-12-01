require 'spec_helper'

describe Server do
  it "is valid with just a name" do
    expect(Server.new).not_to be_valid
    expect(Server.new(name: "my-server")).to be_valid
  end

  describe "#processor_*" do
    it "has a intelligent default value for #processor_system_count" do
      expect(Server.new(name: "srv-01", processor_system_count: 36).processor_system_count).to eq(36)
      expect(Server.new(name: "srv-01", processor_physical_count: 5).processor_system_count).to eq(5)
      expect(Server.new(name: "srv-01", processor_physical_count: 5, processor_cores_per_cpu: 3).processor_system_count).to eq(15)
      expect(Server.new(name: "srv-01").processor_system_count).to eq(1)
    end
  end

  describe "#ipaddresses" do
    let(:server) { FactoryGirl.create(:server) }

    it "updates with an address as a string" do
      server.ipaddresses = [ Ipaddress.new(address: "192.168.99.99", main: true) ]
      server.save
      server.reload
      expect(server.read_attribute(:ipaddress)).to eq 3232260963
      expect(server.ipaddress).to eq "192.168.99.99"
    end

    it "updates with an address as a number between 1 and 32" do
      server.ipaddresses = [ Ipaddress.new(address: "24", main: true) ]
      server.save
      expect(server.reload).to have(1).ipaddresses
      expect(server.ipaddresses.first.address).to eq "255.255.255.0"
      expect(server.read_attribute(:ipaddress)).to eq 4294967040
      expect(server.ipaddress).to eq "255.255.255.0"
    end

    it "leaves ip empty if no main ipaddress" do
      server.ipaddresses = [ Ipaddress.new(address: "10.0.0.1", main: true) ]
      server.save
      expect(server.reload.ipaddress).to eq("10.0.0.1")
      server.ipaddresses = [ Ipaddress.new(address: "24") ]
      server.save
      expect(server.reload.ipaddress).to be_nil
      server.ipaddresses = [ ]
      server.save
      expect(server.reload.ipaddress).to be_nil
    end
  end

  describe "#to_param" do
    it "outputs name if name is alphanum" do
      m = Server.create(name: "blah")
      expect(m.to_param).to eq "blah"
      m = Server.create(name: "Test-3")
      expect(m.to_param).to eq "Test-3"
    end

    it "outpus mongodb's id if not" do
      m = Server.create(name: "( bizarr# n@me )")
      expect(m.to_param).to eq m.id.to_s
    end
  end

  describe "#find" do
    let(:server) { FactoryGirl.create(:server) }

    it "works normally with ids" do
      expect(Server.find(server.id)).to eq server
      expect(Server.find(server.id.to_s)).to eq server
    end

    it "works with identifiers too" do
      expect(Server.find(server.to_param)).to eq server
    end

    it "raises an exception if no existing record with this identifier" do
      expect { Server.find(0) }.to raise_error Mongoid::Errors::DocumentNotFound
      expect { Server.find("non-existent") }.to raise_error Mongoid::Errors::DocumentNotFound #new with mongoid 3
    end

    it "doesn't care if a server was previously named with identifier" do
      old_server = FactoryGirl.create(:server, name: "www")
      old_server.update_attribute(:name, "www-old")
      new_server = FactoryGirl.create(:server, name: "www")
      expect(Server.find("www")).to eq(new_server)
    end
  end

  describe "scopes" do
    let!(:site1) { Site.create!(name: "eu-west") }
    let!(:site2) { Site.create!(name: "us-east") }
    let!(:rack1) { PhysicalRack.create!(name: "rack-1-eu", site_id: site1.id.to_s) }
    let!(:rack2) { PhysicalRack.create!(name: "rack-2-us", site_id: site2.id.to_s) }
    let!(:maint) { Company.create!(name: "Computer shop", is_maintainer: true,
                                   email_infos: [EmailInfo.new(value: "blah@example.net")],
                                   phone_infos: [PhoneInfo.new(value: "555-123456")]) }
    let!(:os)    { OperatingSystem.create!(name: "Linux") }
    let!(:s1)    { Server.create!(name: "srv-app-01", physical_rack_id: rack1.id.to_s,
                                       maintainer_id: maint.id.to_s,
                                       operating_system_id: os.id.to_s) }
    let!(:s2)    { Server.create!(name: "srv-app-02", physical_rack_id: rack2.id.to_s,
                                       virtual: true, puppetversion: nil) }
    let!(:s3)    { Server.create!(name: "srv-db-01", physical_rack_id: rack1.id.to_s,
                                       puppetversion: "0.24.5") }

    it "filters servers by rack" do
      expect(Server.count).to eq 3
      expect(Server.by_rack(rack1.id.to_s).count).to eq 2
      expect(Server.by_rack(rack2.id.to_s).count).to eq 1
    end

    it "filters servers by site" do
      expect(Server.count).to eq 3
      expect(Server.by_site(site1.id.to_s).count).to eq 2
      expect(Server.by_site(site2.id.to_s).count).to eq 1
    end

    it "filters servers by location" do
      expect(Server.by_location("site-#{site1.id}")).to eq Server.by_site(site1.id.to_s)
      expect(Server.by_location("site-0")).to eq []
      expect(Server.by_location("rack-#{rack1.id}")).to eq Server.by_rack(rack1.id.to_s)
      expect(Server.by_location("rack-0")).to eq []
    end

    it "ignores the filter by location if the parameter is invalid" do
      invalid_result = Server.by_location("invalid location")
      expect(invalid_result).to eq Server.scoped
      expect(invalid_result.count).to eq 3
    end

    it "filters servers by maintainer" do
      expect(Server.by_maintainer(maint.id.to_s)).to eq [s1]
    end

    it "filters servers by system" do
      expect(Server.by_system(os.id.to_s).to_a).to eq [s1]
    end

    it "filters servers by virtual" do
      expect(Server.by_virtual(1).to_a).to eq [s2]
    end

    it "returns server with puppet installed" do
      expect(Server.by_puppet(1).to_a).to eq [s3]
    end

    it "returns real servers only" do
      s4 = Server.create!(name: "just-a-name")
      s5 = Server.create!(name: "switch-01", network_device: true)
      s6 = Server.create!(name: "fw-01", network_device: false)
      expect(Server.real_servers.to_a).to match_array([s1, s2, s3, s4, s6])
    end

    it "denormalizes phone_info_value" do
      expect(s1.maintainer_phone).to eq("555-123456")
    end

    it "denormalizes email_info_value" do
      expect(s1.maintainer_email).to eq("blah@example.net")
    end

    describe "#find_or_generate" do
      let!(:server) { Server.create(name: "rake-server") }

      it "finds server by name in priority" do
        srv = Server.find_or_generate("rake-server")
        expect(srv).to eq server
        expect(srv.just_created).to be_falsey
      end

      it "generates a new server if no match with name and identifier" do
        server = Server.where(name: "rake-server3").first
        expect(server).to be_nil
        expect { server = Server.find_or_generate("rake-server3") }.to change(Server, :count).by(+1)
        expect(server).to be_persisted
        expect(server.just_created).to be_truthy
      end
    end
  end

  describe "#stock?" do
    it "is truthy only if it's in a rack that is marked as stock" do
      server = FactoryGirl.create(:server)
      rack = FactoryGirl.create(:rack1)
      expect(server.stock?).to be_falsey
      server.physical_rack = rack
      expect(rack.stock?).to be_falsey
      expect(server.stock?).to be_falsey
      rack.status = PhysicalRack::STATUS_STOCK
      expect(rack.stock?).to be_truthy
      expect(server.stock?).to be_truthy
    end
  end

  describe ".not_backuped" do
    let!(:server) { FactoryGirl.create(:server) }
    let!(:vm)     { FactoryGirl.create(:virtual) }

    it "includes everything by default" do
      expect(Server.not_backuped).to include(server)
      expect(Server.not_backuped).to include(vm)
    end

    it "does not include active servers which have an associated backup job" do
      expect(Server.not_backuped).to include(server)
      server.backup_jobs << BackupJob.create(hierarchy: "/")
      expect(Server.not_backuped).not_to include(server)
    end

    it "does not include servers which have a backup_exclusion" do
      expect(Server.not_backuped).to include(server)
      BackupExclusion.create!(reason: "backuped an other way", servers: [server])
      expect(Server.not_backuped.to_a).not_to include(server)
    end

    it "does not include net devices" do
      expect(Server.not_backuped).to include(server)
      server.update_attribute(:network_device, true)
      expect(Server.not_backuped).not_to include(server)
    end

    it "does not include stock servers" do
      expect(Server.not_backuped).to include(server)
      rack = PhysicalRack.create!(name: "rack-1", site_id: FactoryGirl.create(:room).id.to_s, status: PhysicalRack::STATUS_STOCK)
      server.physical_rack = rack
      server.save
      expect(Server.not_backuped).not_to include(server)
    end
  end

  describe "#can_be_managed_with_puppet?" do
    it "requires having an compatible os defined" do
      srv = FactoryGirl.create(:server)
      expect(srv.operating_system).to be_blank
      expect(srv.can_be_managed_with_puppet?).to be_falsey
      sys = OperatingSystem.create(name: "Ubuntu 11.10")
      srv.update_attribute(:operating_system_id, sys.id.to_s)
      expect(srv.reload.can_be_managed_with_puppet?).to be_falsey
      sys.update_attribute(:managed_with_puppet, true)
      expect(srv.reload.can_be_managed_with_puppet?).to be_truthy
    end
  end

  describe "#software_instances" do
    it "can have many software instance ids" do
      srv = FactoryGirl.create(:server)
      expect(srv.software_instance_ids).to eq []
      expect(srv.software_instances).to eq []
    end
  end

  describe "#hardware_model" do
    it "gets #model (but model is a reserved word for draper)" do
      srv = Server.create!(name: "srv-01", model: "Dell PE 2950")
      expect(srv.hardware_model).to eq("Dell PE 2950")
    end
  end

  describe "mongoid_denormalized" do
    it "updates #physical_rack_full_name correctly" do
      srv = Server.find_or_create_by(name: "srv-01")
      rack = PhysicalRack.create!(name: "Rack-01", site: Site.create!(name: "Room-A"))
      rack2 = PhysicalRack.create!(name: "Rack-02")
      expect(srv.physical_rack_full_name).to be_blank

      srv.update_attributes(physical_rack_id: rack2.id)
      expect(srv.reload.physical_rack_full_name).to eq("Rack-02")

      srv.update_attributes(physical_rack_id: rack.id)
      expect(srv.reload.physical_rack_full_name).to eq("Room-A - Rack-01")

      rack.reload.update_attributes(name: "RCK01")
      expect(srv.reload.physical_rack_full_name).to eq("Room-A - RCK01")

      rack.destroy
      expect(srv.reload.physical_rack_full_name).to be_blank
    end

    it "updates #operating_system_name correctly" do
      srv = Server.find_or_create_by(name: "srv-01")
      sys = OperatingSystem.create!(name: "Linux")
      expect(srv.operating_system_name).to be_blank

      srv.update_attributes(operating_system_id: sys.id)
      expect(srv.reload.operating_system_name).to eq("Linux")

      sys.reload.update_attributes(name: "GNU/Linux")
      expect(srv.reload.operating_system_name).to eq("GNU/Linux")

      sys.destroy
      expect(srv.reload.operating_system_name).to be_blank
    end
  end
end
