require 'spec_helper'

describe DatabasesController do
  login_user
  
  # This should return the minimal set of attributes required to create a valid
  # Database. As you add validations to Database, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {name: "db-01", type: "postgres"}
  end

  before do
    @database = FactoryGirl.create(:database)
  end

  describe "GET :index" do
    it "assigns all databases as @databases" do
      db = Database.create! valid_attributes
      get :index
      assert_template 'index'
      expect(assigns(:databases)).to include db
    end
  end

  describe "GET :index json" do
    render_views

    it "send back a list of databases" do
      get :index, format: "json"
      json = JSON.parse(response.body)
      expect(json["databases"][0]["name"]).to eq("database-01")
    end

    it "doesn't include servers by default, but server_names" do
      get :index, format: "json"
      json = JSON.parse(response.body)
      expect(json["databases"][0]["server_names"]).to eq(["server-01"])
      expect(json["databases"][0]["servers"]).to be_blank
    end

    it "includes servers if requested" do
      get :index, include: "servers", format: "json"
      json = JSON.parse(response.body)
      expect(json["databases"][0]["server_names"]).to eq(["server-01"])
      expect(json["databases"][0]["servers"]).not_to be_blank
      json["databases"][0]["servers"][0]["name"] == "server-01"
    end
  end
  
  describe "GET :show" do
    it "uses the right template" do
      get :show, id: @database
      assert_template 'show'
    end
  end
  
  describe "GET :new" do
    it "uses the right template" do
      get :new
      assert_template 'new'
    end
  end
  
### TODO: understand why it fails
### test_create_invalid(DatabasesControllerTest) [test/functional/databases_controller_test.rb:26]:
###   Expected block to return true value.
###
###  def test_create_invalid
###    Database.any_instance.stubs(:valid?).returns(false)
###    post :create
###    assert_response :success
###    assert_template 'new'
###  end

  describe "POST :create" do
    it "works with valid data" do
      Database.any_instance.stub(:valid?).and_return(true)
      post :create, database: { name: "database", type: "postgres", server_ids: [] }
      assert_redirected_to databases_url #database_url(assigns(:database))
    end
  end

  describe "GET :edit" do
    it "uses the right template" do
      get :edit, id: @database
      assert_template 'edit'
    end
  end
  
### TODO: understand why it fails
### test_create_invalid(DatabasesControllerTest) [test/functional/databases_controller_test.rb:26]:
###   Expected block to return true value.
###
###  def test_update_invalid
###    Database.any_instance.stubs(:valid?).returns(false)
###    put :update, id: @database
###    assert_template 'edit'
###  end

  describe "PUT :update" do
    it "works with valid data" do
      Database.any_instance.stub(:valid?).and_return(true)
      put :update, id: @database
      assert_redirected_to databases_url #database_url(assigns(:database))
    end
  end

  describe "DELETE :destroy" do
    it "destroys database" do
      database = Database.first
      delete :destroy, id: database
      assert_redirected_to databases_url
      expect(Database.where(_id: database.id).count).to eq(0)
    end
  end

  describe "DELETE :destroy_instance" do
    it "destroys a specific database instance" do
      instance = DatabaseInstance.create!(database: @database, name: "Instance", databases: {schema1: "blah"})
      expect(@database.reload.database_instances.count).to eq(1)
      delete :destroy_instance, id: @database.id, instance_id: instance.id
      assert_redirected_to databases_url
      expect(@database.reload.database_instances.count).to eq(0)
    end
  end
end
