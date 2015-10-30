FactoryGirl.define do

	factory :service_provider do

		location							#FactoryGirl.create(:location)
	    company 							#FactoryGirl.create(:company)
	    public_name							"Prestador"
	    active 								true
	    order 								0
	    block_length 						30
	    online_booking 						true

	end
end





