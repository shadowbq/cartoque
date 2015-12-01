require 'spec_helper'

describe DatabaseDecorator do
  before do
    @database = FactoryGirl.create(:database).decorate
  end

  it "displays nodes under a database" do
    expect(@database.servers).to be_present
    expect(@database.name).to eq("database-01")
    expect(@database.servers.map(&:name)).to eq(%w(server-01))
    pretty = @database.pretty_nodes
    expect(pretty).to have_selector('strong > a', text: @database.name)
    expect(pretty).to have_selector('ul > li', text: @database.servers.first.name)
  end

  it "returns <th> headers depending on the database type" do
    expect(Database.new(type: "postgres").decorate.table_headers).to have_selector('th', text: I18n.t(:postgres_instance))
    expect(Database.new(type: "postgres").decorate.table_headers).to include '</span>' #let's be sure our content is not escaped
    expect(Database.new(type: "oracle").decorate.table_headers).to have_selector('th', text: I18n.t(:oracle_instance))
    expect(Database.new(type: "not valid").decorate.table_headers).to be_nil
  end

  it "returns different columns names depending on the type" do
    expect(Database.new(type: "postgres").decorate.table_column_names).to include "postgres_instance"
    expect(Database.new(type: "oracle").decorate.table_column_names).to include "oracle_instance"
    expect(Database.new(type: "not valid").decorate.table_column_names).to be_nil
  end
end
