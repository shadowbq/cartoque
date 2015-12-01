require 'spec_helper'

describe SoftwaresController do
  login_user

  before do
    @software = FactoryGirl.create(:software)
  end

  it "gets index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:softwares)
  end

  it "gets new" do
    get :new
    assert_response :success
  end

  it "creates software" do
    expect{ post :create, software: {"name" => "app-01"} }.to change(Software, :count)
    assert_redirected_to software_path(assigns(:software))
  end

  it "shows software" do
    get :show, id: @software.to_param
    assert_response :success
  end

  #TODO: refactor it
  #TODO: move it to a request spec
  it "accesss the rest/xml API" do
    app_inst = SoftwareInstance.new(name: "prod", authentication_method: "none", software_id: @software.id.to_s)
    app_inst.servers = [ FactoryGirl.create(:server), FactoryGirl.create(:virtual) ]
    app_inst.save
    @software.reload
    get :show, id: @software.to_param, format: :xml
    expect(response.body).to have_selector :css, "software>_id", @software.id.to_s
    assert_equal 1, @software.software_instances.count
    expect(response.body).to have_selector :css, "software>software-instances>software-instance", 1
    assert_equal 2, @software.software_instances.first.servers.count
    expect(response.body).to have_selector :css, "software>software-instances>software-instance>servers>server", 2
  end

  it "accesss an software through its identifier" do
    get :show, id: @software.to_param, format: :xml
    expect(response.body).to include "<_id>#{@software.id}</_id>"
  end

  it "gets edit" do
    get :edit, id: @software.to_param
    assert_response :success
  end

  it "updates software" do
    put :update, id: @software.to_param, software: {"name" => "app-02"}
    assert_redirected_to software_path(assigns(:software))
  end

  it "destroys software" do
    expect{ delete :destroy, id: @software.to_param }.to change(Software, :count).by(-1)
    assert_redirected_to softwares_path
  end

  describe "contact relations" do
    let!(:app)   { Software.create(name: "Skynet") }
    let!(:role)  { Role.create(name: "Developer") }
    let!(:user1) { Contact.create(last_name: "Mitnick", first_name: "Kevin") }
    let!(:user2) { Contact.create(last_name: "Hoffman", first_name: "Milo") }

    it "allows creation with contacts" do
      contacts_count = Contact.count
      relations_count = Relationship.count

      expect(Software.where(name: "webapp-01").first).to be_blank

      post :create, software: { name: "webapp-01", relationships_map: { role.id.to_s => "#{user1.id},#{user2.id}" } }
      webapp = Software.where(name: "webapp-01").first


      expect(webapp.contacts_with_role(role)).to match_array([user1, user2])
      expect(Relationship.count).to eq relations_count + 1

      webapp.destroy
      expect(Relationship.count).to eq relations_count
    end

    # NB: inherited_resources now caches params in a request, so you cannot have a test
    # with two different params hashes (didn't dug too deep into this for now)
    it "allows update with contacts" do
      put :update, id: app.id, software: { name: "Skynet", relationships_map: { role.id.to_s => "#{user1.id},#{user2.id}" } }
      expect(app.reload.contacts_with_role(role)).to match_array([user1, user2])
    end

    # NB: inherited_resources now caches params in a request, so you cannot have a test
    # with two different params hashes (didn't dug too deep into this for now)
    it "empties contacts" do
      app.update_attributes(relationships_map: { role.id.to_s => "#{user1.id},#{user2.id}" })
      expect(app.reload.contacts_with_role(role)).not_to be_blank
      put :update, id: app.id, software: { name: "webapp-01", relationships_map: { } }
      expect(app.reload.contacts_with_role(role)).to be_blank
    end
  end
end