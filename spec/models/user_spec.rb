require 'spec_helper'

describe User do
  before do
    @user = FactoryGirl.create(:user)
  end

  it "has a unique name" do
    other = User.new(name: @user.name)
    expect(other).not_to be_valid
    expect(other.errors.keys).to eq([:name])
    expect(other.errors[:name]).to eq([I18n.t("mongoid.errors.messages.taken")])
  end

  it "has a contextual datacenter" do
    Datacenter.destroy_all
    User.destroy_all
    expect(Datacenter.count).to eq(0)

    user = FactoryGirl.create(:user)
    expect(user.preferred_datacenter).to be_present
    expect(user.preferred_datacenter).to be_persisted
  end

  it "has a unique provider+uid" do

    
  end

  describe "#settings" do
    it "alwayss be a hash" do
      expect(User.new.settings).to eq Hash.new
    end

    it "serializes settings" do
      hsh = { "a" => "b" }
      @user.settings = hsh
      @user.save
      expect(@user.reload.settings).to eq hsh
    end
  end

  describe "#set_setting" do
    it "sets a setting (without saving the user)" do
      expect(@user.settings).to be_blank
      @user.set_setting("a", "b")
      @user.save
      expect(@user.reload.settings["a"]).to eq "b"
    end
  end

  describe "#update_setting" do
    it "sets a setting and save the user" do
      expect(@user.settings).to be_blank
      @user.update_setting("a", "b")
      expect(@user.reload.settings["a"]).to eq "b"
    end

    it "stringifys key" do
      expect(@user.settings).to be_blank
      @user.update_setting(:a, "c")
      expect(@user.reload.settings["a"]).to eq "c"
    end
  end

  describe "#visible_datacenters" do
    it "accepts datacenters" do
      datacenter = FactoryGirl.create(:datacenter)
      @user.update_attribute(:visible_datacenter_ids, [datacenter.id.to_s])
      expect(@user.reload.visible_datacenters).to eq [datacenter]
    end
  end
end
