require 'spec_helper'

describe "I18n" do
  describe "when not authenticated" do
    after { page.set_headers("HTTP_ACCEPT_LANGUAGE" => nil) }

    it "leaves I18n.locale to 'en' if no HTTP header available", type: :request do
      expect(I18n.default_locale).to eq :en
      visit "/users/sign_in"
      expect(I18n.locale).to eq :en
    end

    it "sets I18n.locale to HTTP_ACCEPT_LANGUAGE header first 2 letters if provided and locale exists" do
      page.set_headers("HTTP_ACCEPT_LANGUAGE" => "bleh")
      visit "/users/sign_in"
      expect(I18n.locale).to eq :en

      page.set_headers("HTTP_ACCEPT_LANGUAGE" => "fr")
      visit "/users/sign_in"
      expect(I18n.locale).to eq :fr

      page.set_headers("HTTP_ACCEPT_LANGUAGE" => "french")
      visit "/users/sign_in"
      expect(I18n.locale).to eq :fr
    end
  end

  describe "when authenticated" do
    before do
      @user = FactoryGirl.create(:user)
      @controller = SoftwaresController.new
      @controller.request    = ActionController::TestRequest.new
      @controller.stub(:current_user).and_return(@user)
      I18n.locale = I18n.default_locale
    end

    it "takes the locale if possible" do
      expect(I18n.locale).not_to eq :fr
      @user.update_setting("locale", "fr")
      @controller.send(:set_locale)
      expect(I18n.locale).to eq :fr
    end

    it "doesn't take user locale if it's invalid" do
      expect(I18n.locale).to eq :en
      @user.update_setting("locale", "bl")
      @controller.send(:set_locale)
      expect(I18n.locale).to eq :en
      @user.update_setting("locale", "")
      @controller.send(:set_locale)
      expect(I18n.locale).to eq :en
    end
  end
end
