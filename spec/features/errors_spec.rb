require 'spec_helper'

describe 'Error pages' do
  let(:user) { FactoryGirl.create(:user) }
  before { login_as user }

  it "catches DocumentNotFound errors" do
    visit '/softwares/4a17dec32007653b18000001'
    page.status_code.should == 404
    page.should have_content "These are not the droids you're looking for"
  end
end
