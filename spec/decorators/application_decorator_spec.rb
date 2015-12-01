require 'spec_helper'

describe SoftwareDecorator do
  before do
    @a = SoftwareDecorator.new(nil) #dummy object to test methods...
  end

  describe "I18n methods" do
    it "aliases I18n.t()" do
      key = "mongoid.error.messages.invalid_time"
      expect(@a.t(key, value: "blah")).to eq I18n.t(key, value: "blah")
    end

    it "aliases I18n.l()" do
      date = Date.today
      expect(@a.l(date)).to eq I18n.l(date)
    end
  end
end
