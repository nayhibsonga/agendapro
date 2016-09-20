FactoryGirl.define do

	factory :service do

		price 				5000
		duration 			30
		description 		"Ejemplo de servicio"
		group_service 		false
		capacity 			1
		waiting_list 		false
		company 			#FactoryGirl.create(:company)
		service_category 	#FactoryGirl.create(:service_category)
		active 				true
		show_price 			true
		order 				0
		outcall 			false
		has_discount 		false
		discount 			0
		online_payable 		false
		comission_value 	0
		comission_option 	0
		online_booking 		true

	end
end