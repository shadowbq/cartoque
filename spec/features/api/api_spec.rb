require 'spec_helper'

describe "General API" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:server) { Server.create!(name: "srv-01") }

  before { page.set_headers("HTTP_X_API_TOKEN" => user.authentication_token) }
  after { page.set_headers("HTTP_X_API_TOKEN" => nil) }

  it "forces format to json if api token + no format specified" do
    visit servers_path
    expect(page.status_code).to eq(200)
    expect(page.response_headers['Content-Type']).to match %r(^application/json)
    res = JSON.parse(page.body) rescue nil
    expect(res).not_to be nil
  end
end
