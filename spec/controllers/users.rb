require 'rails_helper'

describe UsersController do

	login_user

	it "should have a current user" do
		subject.current_user.should_not be_nil
	end
  
	it "renders the agenda" do

		get :agenda
		subject.current_user.should_not be_nil
		assigns(:activeBookings).should_not be_nil
		assigns(:lastBookings).should_not be_nil
		response.should render_template :agenda

	end

end