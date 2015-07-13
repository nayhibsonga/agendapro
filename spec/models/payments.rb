require 'rails_helper'

describe Payment do 

	it "should be valid" do

		@receipt_type = FactoryGirl.create(:receipt_type)
		@payment_method = FactoryGirl.create(:payment_method)
		@payment = build(:payment, receipt_type: @receipt_type, payment_method: @payment_method)

		expect(@payment).to be_valid

		# @role = FactoryGirl.create(:role)
		# @user = build(:user, role: @role)
		# @new_user = User.new(@user.attributes.to_options)
		# @new_user.id = nil
		# @new_user.should be_valid

	end

end