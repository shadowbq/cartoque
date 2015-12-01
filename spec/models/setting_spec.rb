require 'spec_helper'

describe Setting do
  describe "#safe_cas_server" do
    before do
      @default_value = Setting.fields["cas_server"].default_val
    end

    it "returns the #cas_server if set" do
      expect(Setting.update_attribute(:cas_server, "http://cas.example.com")).to be_truthy
      expect(Setting.safe_cas_server).to eq "http://cas.example.com"
    end

    it "returns the default value if #cas_server is blank or nearly blanked" do
      expect(Setting.update_attribute(:cas_server, " ")).to be_truthy
      expect(Setting.safe_cas_server).to eq @default_value
      expect(@default_value).not_to be_blank
    end
  end
end
