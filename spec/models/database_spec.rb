require 'spec_helper'
require 'server'

class Server
  def postgres_file
    Rails.root.join("spec/data/postgres/#{name.downcase}.txt").to_s
  end

  def oracle_file
    Rails.root.join("spec/data/oracle/#{name.downcase}.txt").to_s
  end

  def mysql_file
    Rails.root.join("spec/data/mysql/#{name.downcase}.txt").to_s	  
  end
end

describe Database do
  it "has at least a name and a type" do
    expect(Database.new(name: "blah")).not_to be_valid
    expect(Database.new(name: "blah", type: "postgres")).to be_valid
  end

  context "scopes" do
    it "filters databases by name" do
      Database.create(name: "one", type: "postgres")
      Database.create(name: "two", type: "postgres")
      Database.create(name: "three", type: "oracle")
      expect(Database.by_name("one").map(&:name)).to eq ["one"]
      expect(Database.by_name("t").map(&:name)).to eq ["two", "three"]
    end
  end

  it "returns total size handled by a database cluster server" do
    expect(Database.new.size).to eq 0
    pg  = Database.create!(name: "pg-cluster",  type: "postgres")
    pg.database_instances.create(name: '8.4', databases:{'app01'=>1, 'app02'=>2})
    pg.database_instances.create(name: '9.0', databases:{'app01-dev'=>4, 'app02-dev'=>8})
    expect(pg.size).to eq(15)
  end

  describe "#server_ids=" do
    it "should update servers correctly" do
      db = Database.create!(name: "pg-cluster", type: "postgres")
      srv = FactoryGirl.create(:server)
      vm  = FactoryGirl.create(:virtual)
      db.server_ids = [srv.id.to_s]
      db.save!
      expect(db.reload.servers).to eq([srv])
      db.server_ids = [vm.id.to_s]
      db.save!
      expect(db.reload.servers).to eq([vm])
      expect(srv.database_id).to be_blank
    end
  end

  describe "#distribution" do
    before do
      srv = FactoryGirl.create(:server)
      vm  = FactoryGirl.create(:virtual)
      pg  = Database.create!(name: "pg-cluster",  type: "postgres", servers: [srv])
      pg.database_instances.create(name: '8.4', databases:{'app01'=>6054180, 'app02'=>293962020, 'app03'=>5341476, 'app04'=>292479268, 'app05'=>11149754660})
      pg.database_instances.create(name: '9.0', databases:{'app01-dev'=>5311356, 'app02-dev'=>6073212, 'app03-dev'=>11152252, 'app04-dev'=>17543220092})
      ora = Database.create!(name: "ora-cluster", type: "oracle",   servers: [vm])
      ora.database_instances.create(name: 'dev03', databases:{'app101'=>8755412992, 'app102'=>2144600064, 'app103'=>1191247872})
    end

    it "returns a distribution compatible with d3.js source" do
      expect(Database.all.map(&:servers).map(&:size)).to eq [1, 1]
      distrib = Database.d3_distribution
      #top key
      expect(distrib.keys).to match_array(%w(name children))
      expect(distrib["children"]).to have_exactly(3).items
      #grouped by server type
      expect(distrib["children"].inject([]){|memo,h| memo << h["name"]}).to match_array(%w(postgres oracle mysql))
      #grouped by clusters
      pg = distrib["children"].detect{|h| h["name"] == "postgres"}["children"]
      expect(pg).to have_exactly(1).item
      expect(pg.first["name"]).to eq("pg-cluster")
      #grouped by db engines
      dbs = pg.first["children"].first["children"]
      dbs_str = dbs.map{|h| "#{h["name"]}:#{h["size"]}"}.sort.join(" ")
      expect(dbs_str).to eq("app01:6054180 app02:293962020 app03:5341476 app04:292479268 app05:11149754660")
    end

    it "defaults to Database.all" do
      expect(Database.d3_distribution).to eq Database.d3_distribution(Database.includes(:servers))
    end
  end
end
