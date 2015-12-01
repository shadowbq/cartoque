require 'spec_helper'

describe "components/show" do
  before(:each) do
    @component = assign(:component, stub_model(Component,
      name: "Name",
      website: "Website",
      description: "Description"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Name/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Website/)
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    expect(rendered).to match(/Description/)
  end
end
