require "spec_helper"

describe PostitsController do
  login_user

  let(:app) { FactoryGirl.create(:software) }
  let(:postit) { app.create_postit(content: "Don't forget I'm a shiny app!") }

  describe "#find_commentable" do
    it "finds commentable based on params if present" do
      get :new, format: "js", commentable_type: "Software", commentable_id: app.id.to_s
      expect(assigns(:commentable)).to eq(app)
    end

    it "raises if wrong commentable constant name in params" do
      get :new, commentable_type: "Softwarez", commentable_id: app.id.to_s
      expect(response.status).to eq(404)
    end

    it "raises if wrong commentable id in params" do
      get :new, commentable_type: "Software", commentable_id: app.id.to_s+"blah"
      expect(response.status).to eq(404)
    end

    it "raises if wrong params" do
      get :new
      expect(response.status).to eq(404)
    end
  end

  describe "#new" do
    it "builds a new postit" do
      get :new, format: "js", commentable_type: "Software", commentable_id: app.id.to_s
      expect(assigns(:postit)).to be_a Postit
    end
  end

  describe "#create" do
    it "creates a new postit with proposed content" do
      post :create, format: "js", commentable_type: "Software", commentable_id: app.id.to_s,
                    back_url: '/settings', postit: { content: "Blah" }
      expect(response).to redirect_to '/settings'
      expect(app.reload.postit.content).to eq("Blah")
    end
  end

  describe "#edit" do
    it "edits an existing postit" do
      get :edit, id: postit.id, format: "js", commentable_type: "Software", commentable_id: app.id.to_s
      expect(assigns(:postit)).to eq(postit)
    end
  end

  describe "#update" do
    it "updates the content of an existing postit" do
      put :update, id: postit.id, format: "js", commentable_type: "Software", commentable_id: app.id.to_s,
                   back_url: '/settings', postit: { content: "Foo" }
      expect(response).to redirect_to '/settings'
      expect(app.reload.postit.content).to eq("Foo")
    end
  end

  describe "#destroy" do
    it "deletes a postit and redirect back" do
      delete :destroy, id: postit.id, format: "js", commentable_type: "Software", commentable_id: app.id.to_s,
                       back_url: '/settings'
      expect(response).to redirect_to '/settings'
      expect(app.reload.postit).to be_blank
    end
  end
end
