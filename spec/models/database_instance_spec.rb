require 'spec_helper'

describe DatabaseInstance do
  let(:database) { Database.create!(name: "srv-01", type: "postgres") }
  let(:database2) { Database.create!(name: "srv-02", type: "postgres") }

  it "has at least a name and a database" do
    expect { database.database_instances.create! }.to raise_error(Mongoid::Errors::Validations)
    expect { database.database_instances.create!(name: "blah", databases: nil) }.to raise_error(Mongoid::Errors::Validations)
    expect { database.database_instances.create!(name: "blah") }.not_to raise_error
    expect(database.database_instances.first.databases).to eq({})
    expect { database.database_instances.create!(name: "bleh", databases: {}) }.not_to raise_error
  end

  it "guarantees uniqueness of name in a single database" do
    expect { database.database_instances.create!(name: "blah", databases: {}) }.not_to raise_error
    expect { database.database_instances.create!(name: "blah", databases: {}) }.to raise_error(Mongoid::Errors::Validations)
    expect { database2.database_instances.create!(name: "blah", databases: {}) }.not_to raise_error
  end

  it "calculates the size of its databases" do
    database.database_instances.create!(name: "blah", databases: { first: 1, two: 2, three: 3 })
    expect(database.database_instances.last.size).to eq(6)
    database.database_instances.create!(name: "bleh", databases: {})
    expect(database.database_instances.last.size).to eq(0)
  end
end
