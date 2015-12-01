require 'spec_helper'

describe "Components" do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }

  describe "GET /components" do
    it "list all components" do
      visit components_path
      expect(page.status_code).to be(200)
    end
  end
end
