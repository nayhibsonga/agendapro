FactoryGirl.define do

	factory :service_provider do

		location							#FactoryGirl.create(:location)
	    company 							#FactoryGirl.create(:company)
	    notification_email					"iegomez@agendapro.cl"
	    public_name							"Proveedor"
	    active 								true
	    order 								0
	    block_length 						30
	    booking_configuration_email 		0
	    online_booking 						true

	end
end





