require 'spec_helper'

describe Role do
  it "requires presence of #name" do
    expect(Role.new).not_to be_valid
    expect(Role.new(name: "Blah")).to be_valid
  end

  it "is unique by name" do
    Role.create!(name: "Blah")
    expect(Role.new(name: "Blah")).not_to be_valid
  end

  it "doesn't alter position if provided" do
    expect(Role.new(name: "Blah", position: 37).position).to eq(37)
  end

  it "is sorted by position asc by default" do
    Role.create!(name: "Two", position: 2)
    Role.create!(name: "One", position: 1)
    expect(Role.all.to_a.map(&:name)).to eq(%w(One Two))
  end

  it "auto increments position field" do
    expect(Role.count).to eq(0)
    expect(Role.create!(name: "One").position).to eq(1)
    expect(Role.create!(name: "Two").position).to eq(2)
  end
end
