require 'spec_helper'

describe PhysicalLink do
  it "is able to add a physical link to a server" do
    from, to = FactoryGirl.create(:server), FactoryGirl.create(:virtual)
    expect do
      PhysicalLink.create(server: from, switch: to, link_type: "eth")
    end.to change(PhysicalLink, :count).by(+1)
  end
end
