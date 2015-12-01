require 'spec_helper'

describe License do
  let!(:server) { FactoryGirl.create(:server) }
  let!(:license1) { License.create(editor:"softcompany1", key: "XCDEZF", title: "Soft1 license") }
  let!(:license2) { License.create(editor:"softcompany2", key: "ADFRTG", server_ids: [server.id]) }

  it "has servers" do
    license1.server_ids = [server.id]
    license1.save
    license1.reload
    expect(license1.servers).to include server
    #inverse
    vm = Server.create!(name: "vm-blah", license_ids: [license2.id])
    expect(vm.license_ids).to include license2.id
    expect(license2.reload.server_ids).to include vm.id
  end

  describe "scopes" do
    before do
    end

    it "filters licenses by editor" do
      expect(License.by_editor("softcompany2").to_a).to eq([license2])
    end

    it "filters licenses by key" do
      expect(License.by_key("AD").to_a).to eq([license2])
    end

    it "filters licenses by title" do
      expect(License.by_title("Soft1").to_a).to eq([license1])
    end

    it "filters licenses by server id" do
      server.licenses = [license2]
      server.save
      expect(License.by_server(server.id).to_a).to eq([license2])
    end
  end
end
