FactoryGirl.define do

    factory :company do

    	name 					"Company1"
		web_address 			"company1"
		logo 					"MyLogo"
		months_active_left		1.0
		plan 					#Factory.create(:plan)
		payment_status 			#Factory.create(:payment_status)
		description 			"Test company 1"
		cancellation_policy		""
		active 					true
		due_amount 				0.0
		due_date				nil
		owned 					true
		country

    end

end



