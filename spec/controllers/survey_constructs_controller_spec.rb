require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

RSpec.describe SurveyConstructsController, :type => :controller do

  # This should return the minimal set of attributes required to create a valid
  # SurveyConstruct. As you add validations to SurveyConstruct, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SurveyConstructsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET index" do
    it "assigns all survey_constructs as @survey_constructs" do
      survey_construct = SurveyConstruct.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:survey_constructs)).to eq([survey_construct])
    end
  end

  describe "GET show" do
    it "assigns the requested survey_construct as @survey_construct" do
      survey_construct = SurveyConstruct.create! valid_attributes
      get :show, {:id => survey_construct.to_param}, valid_session
      expect(assigns(:survey_construct)).to eq(survey_construct)
    end
  end

  describe "GET new" do
    it "assigns a new survey_construct as @survey_construct" do
      get :new, {}, valid_session
      expect(assigns(:survey_construct)).to be_a_new(SurveyConstruct)
    end
  end

  describe "GET edit" do
    it "assigns the requested survey_construct as @survey_construct" do
      survey_construct = SurveyConstruct.create! valid_attributes
      get :edit, {:id => survey_construct.to_param}, valid_session
      expect(assigns(:survey_construct)).to eq(survey_construct)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new SurveyConstruct" do
        expect {
          post :create, {:survey_construct => valid_attributes}, valid_session
        }.to change(SurveyConstruct, :count).by(1)
      end

      it "assigns a newly created survey_construct as @survey_construct" do
        post :create, {:survey_construct => valid_attributes}, valid_session
        expect(assigns(:survey_construct)).to be_a(SurveyConstruct)
        expect(assigns(:survey_construct)).to be_persisted
      end

      it "redirects to the created survey_construct" do
        post :create, {:survey_construct => valid_attributes}, valid_session
        expect(response).to redirect_to(SurveyConstruct.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved survey_construct as @survey_construct" do
        post :create, {:survey_construct => invalid_attributes}, valid_session
        expect(assigns(:survey_construct)).to be_a_new(SurveyConstruct)
      end

      it "re-renders the 'new' template" do
        post :create, {:survey_construct => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested survey_construct" do
        survey_construct = SurveyConstruct.create! valid_attributes
        put :update, {:id => survey_construct.to_param, :survey_construct => new_attributes}, valid_session
        survey_construct.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested survey_construct as @survey_construct" do
        survey_construct = SurveyConstruct.create! valid_attributes
        put :update, {:id => survey_construct.to_param, :survey_construct => valid_attributes}, valid_session
        expect(assigns(:survey_construct)).to eq(survey_construct)
      end

      it "redirects to the survey_construct" do
        survey_construct = SurveyConstruct.create! valid_attributes
        put :update, {:id => survey_construct.to_param, :survey_construct => valid_attributes}, valid_session
        expect(response).to redirect_to(survey_construct)
      end
    end

    describe "with invalid params" do
      it "assigns the survey_construct as @survey_construct" do
        survey_construct = SurveyConstruct.create! valid_attributes
        put :update, {:id => survey_construct.to_param, :survey_construct => invalid_attributes}, valid_session
        expect(assigns(:survey_construct)).to eq(survey_construct)
      end

      it "re-renders the 'edit' template" do
        survey_construct = SurveyConstruct.create! valid_attributes
        put :update, {:id => survey_construct.to_param, :survey_construct => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested survey_construct" do
      survey_construct = SurveyConstruct.create! valid_attributes
      expect {
        delete :destroy, {:id => survey_construct.to_param}, valid_session
      }.to change(SurveyConstruct, :count).by(-1)
    end

    it "redirects to the survey_constructs list" do
      survey_construct = SurveyConstruct.create! valid_attributes
      delete :destroy, {:id => survey_construct.to_param}, valid_session
      expect(response).to redirect_to(survey_constructs_url)
    end
  end

end
