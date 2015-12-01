require 'spec_helper'

describe ServerDecorator do
  let(:server) { ServerDecorator.decorate(FactoryGirl.create(:server)) }

  describe "#badges" do
    it "is empty if the server has no badge" do
      expect(server.badges).to eq("")
    end

    it "concatenates all the badges for a server" do
      server.network_device = true
      server.virtual = true
      server.puppetversion = "2.6"
      badges = server.badges
      expect(badges).to have_selector("div", count: 3)
    end
  end

  describe "#network_device_badge" do
    it "is empty for normal servers" do
      expect(server.network_device_badge).to eq("")
    end

    it "displays an image for network devices" do
      server.network_device = true
      expect(server.network_device_badge).to have_selector("div>img")
    end
  end
  
  describe "#puppet_badge" do
    it "is empty for non-puppetized servers" do
      expect(server.puppet_badge).to eq("")
    end

    it "displays a P if puppetversion is present" do
      server.puppetversion = "2.6"
      expect(server.puppet_badge).to have_selector("div", text: "P")
    end
  end
  
  describe "#virtual_badge" do
    it "is empty for physical servers" do
      expect(server.virtual_badge).to eq("")
    end

    it "displays a V for virtual machines" do
      server.virtual = true
      expect(server.virtual_badge).to have_selector("div", text: "V")
    end
  end

  describe "hardware details" do
    it "displays cpu" do
      expect(server.cpu).to eq %(4 * 4 cores, 3.2 GHz<span class="processor-reference">Xeon 2300</span>)
      server.processor_cores_per_cpu = nil
      expect(server.cpu).to eq %(4 * 3.2 GHz<span class="processor-reference">Xeon 2300</span>)
      server.processor_cores_per_cpu = 1
      expect(server.cpu).to eq %(4 * 3.2 GHz<span class="processor-reference">Xeon 2300</span>)
    end

    it "displays ram" do
      expect(server.memory).to eq "42GB"
    end

    it "displays disks" do
      expect(server.disks).to eq "5 * 13G (SAS)"
    end
  end

  describe "#short_line" do
    it "displays server with full details" do
      line = server.short_line
      expect(line).to have_selector(:css, "span.server-link a", text: "server-01")
      expect(line).to have_selector(:css, "span.server-summary", text: "4 * 4 cores, 3.2 GHz | 42GB | 5 * 13G (SAS)")
    end

    it "displays server without raising an exception if no details" do
      #TODO: restore this when switching back to "Server"
      #line = Server.new(name: "server-03").decorate.short_line
      line = ServerDecorator.decorate(Server.new(name: "server-03")).short_line
      expect(line).to have_selector(:css, "span.server-link a", text: "server-03")
    end

    it "displays nothing in server details if no details available" do
      #TODO: restore this when switching back to "Server"
      #line = Server.new(name: "srv").decorate.short_line
      line = ServerDecorator.decorate(Server.new(name: "srv")).short_line
      expect(line).to have_selector(:css, "span.server-summary", text: "")
    end
  end

  describe "#maintenance_limit" do
    it "returns 'no' if maintenance end date is blank" do
      expect(server.maintenance_limit).to have_selector(:css, "span.maintenance-critical", text: I18n.t(:word_no))
    end

    it "returns the date if server is maintained until the next 2 years" do
      server.maintained_until = Date.today + 2.years
      expect(server.maintenance_limit).to eq(I18n.l(server.maintained_until))
    end

    it "returns warning or critical <span> if under 6 or 12 months" do
      server.maintained_until = Date.today - 2.years
      expect(server.maintenance_limit).to have_selector(:css, "span.maintenance-critical")
      server.maintained_until = Date.today + 5.months
      expect(server.maintenance_limit).to have_selector(:css, "span.maintenance-critical")
      server.maintained_until = Date.today + 11.months
      expect(server.maintenance_limit).to have_selector(:css, "span.maintenance-warning")
    end
  end

  describe "#serial_numbers" do
    it "outputs machine serial_number if no extension" do
      expect(Server.new.decorate.serial_numbers).to eq([])
      expect(server.serial_numbers).to eq([ "12345" ])
    end

    it "includes server extensions' serial numbers if any" do
      expect(FactoryGirl.build(:server_with_extensions).decorate.serial_numbers).to eq([ "12345", "54321 (storage)" ])
    end
  end
end
