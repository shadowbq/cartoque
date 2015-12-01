require 'spec_helper'

describe ContactsController, :type => :controller do
  login_user

  describe "GET /index" do
    before do
      @doe = Contact.create!(last_name: "Doe")
      @smith = Contact.create!(last_name: "Smith")
    end

    it "assigns @contacts" do
      get :index
      expect(assigns(:contacts).to_a).to match_array([@doe, @smith])
    end

    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
    end

    it "filters contacts by name" do
      get :index, search: "smi"
      expect(assigns(:contacts).to_a).to eq [@smith]
    end

    it "sorts contacts correctly" do
      get :index, sort: "last_name", direction: "desc"
      expect(assigns(:contacts).to_a).to eq [@smith, @doe]
    end

    describe "with internal visibility" do
      before do
        @bob = Contact.create!(last_name: "Bob", internal: true)
        @vendor = Company.create!(name: "Manufacturer inc.")
        @team = Company.create!(name: "Our team (internal)", internal: true)
      end

      it "shouldn't display internal contacts/companies by default" do
        get :index
        expect(assigns(:contacts).to_a).not_to include @bob
        expect(assigns(:companies).to_a).to include @vendor
        expect(assigns(:companies).to_a).not_to include @team
      end

      it "displays internal contacts/companies with some more params or session" do
        get :index, with_internals: "1"
        expect(assigns(:contacts).to_a).to include @bob
        expect(assigns(:companies).to_a).to include @team
        #and keep it in session...
        expect(controller.send(:current_user).settings["contacts_view_internals"]).to eq "1"
        get :index
        expect(assigns(:contacts).to_a).to include @bob
        expect(assigns(:companies).to_a).to include @team
      end
    end
  end
end
