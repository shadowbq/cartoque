require 'spec_helper'

describe "Welcome" do

  let(:user) { FactoryGirl.create(:user) }

  before do
    login_as user
  end

  it "includes a welcome message" do
    visit root_path
    expect(page.body).to include "Welcome to Cartoque"
  end

  it "includes stats about softwares" do
    Software.create!(name: "app-01")
    Software.create!(name: "app-02")
    visit root_path
    expect(page.body).to include "2 softwares"
  end
end
