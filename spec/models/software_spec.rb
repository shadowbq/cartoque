require 'spec_helper'
require 'software'

class Software
  def self.dokuwiki_dir
    File.expand_path("spec/data/dokuwiki", Rails.root)
  end
end

describe Software do
  it "has a name" do
    expect(Software.new).not_to be_valid
    expect(Software.new(name: "fakeapp")).to be_valid
  end

  describe "Software.search" do
    before do
      Software.create!(name: "app-01")
      Software.create!(name: "app-02")
    end

    it "returns every software when query is blank or is not a string" do
      expect(Software.count).not_to eq(0)
      expect(Software.search(nil).length).to eq(Software.count)
      expect(Software.search("").length).to eq(Software.count)
    end

    it "shouldn't be case sensitive" do
      expect(Software.search("App-01").length).to eq 1
    end
  end

  describe "Software#sorted_software_instances" do
    it "resists to empty arrays" do
      app = FactoryGirl.create(:software)
      expect(app.software_instances).to eq []
      expect(app.sorted_software_instances).to eq []
    end

    it "is ordered with prod, ecole, preprod first" do
      app = FactoryGirl.create(:software)
      SoftwareInstance.create!(name: "ecole", authentication_method: "none", software_id: app.id)
      SoftwareInstance.create!(name: "aaaa", authentication_method: "none", software_id: app.id)
      SoftwareInstance.create!(name: "ffff", authentication_method: "none", software_id: app.id)
      SoftwareInstance.create!(name: "zzzz", authentication_method: "none", software_id: app.id)
      SoftwareInstance.create!(name: "prod", authentication_method: "none", software_id: app.id)
      SoftwareInstance.create!(name: "preprod", authentication_method: "none", software_id: app.id)
      app.reload
      expect(app).to have(6).software_instances
      expect(app.sorted_software_instances.map(&:name)).to eq %w(prod ecole preprod aaaa ffff zzzz)
    end
  end

  describe "#dokuwiki_pages" do
    it "returns no doc" do
      app = Software.new(name: "app-03")
      expect(app.dokuwiki_pages).to eq []
    end

    it "returns doc corresponding to */app_name/* or */app_name.txt" do
      app = Software.new(name: "app-01")
      expect(app.dokuwiki_pages.size).to eq(2)
      expect(app.dokuwiki_pages).to include("app-01")
      expect(app.dokuwiki_pages).to include("app-01:doc")
    end

    it "returns doc depending on linked software_urls" do
      app = Software.new(name: "software-02")
      app_instance = SoftwareInstance.new(name: "prod")
      app_url = SoftwareUrl.new(url: "http://app-02.example.com/index.php")
      app_instance.software_urls << app_url
      app.software_instances << app_instance
      expect(app.dokuwiki_pages).to eq ["app-02.example.com"]
    end
  end

  describe "#relationships" do
    let!(:app)  { Software.create(name: "Skynet") }
    let!(:role) { Role.create(name: "Developer") }
    let!(:user) { Contact.create(last_name: "Mitnick", first_name: "Kevin") }
    let!(:rel)  { Relationship.create(item: app, role: role, contacts: [user]) }

    it "returns a map of relationships grouped by role" do
      map = app.relationships_map
      expect(map["not-a-key"]).to eq([])
      expect(map[role.id.to_s]).to eq([ rel ])
    end
  end

  describe ".find" do
    let!(:app) { Software.create!(name: "Red girl", ci_identifier: "rdg") }

    it "accepts passing the slug" do
      expect(Software.find(app.slug)).to eq(app)
    end

    it "accepts passing the ci_identifier" do
      expect(Software.find("rdg")).to eq(app)
    end

    it "prioritize the ci_identifier over the slug" do
      app2 = Software.create!(name: "Reddie", ci_identifier: app.slug)
      expect(Software.find(app.slug)).to eq(app2)
    end

    it "works with id" do
      expect(Software.find(app.id.to_s)).to eq(app)
    end
  end
end
