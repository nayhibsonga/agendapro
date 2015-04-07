FactoryGirl.define do

	factory :booking do

		start	"2015-04-03 11:15:00"
	    notes 
	    service_provider #FactoryGirl.create(:service_provider)
	    user_id
	    service #FactoryGirl.create(:service)
	    location #FactoryGirl.create(:location)
	    status #FactoryGirl.create(:status)
	    promotion_id
	    created_at "2015-03-31 14:41:46"
	    updated_at "2015-03-31 14:42:34"
	    company_comment
	    web_origin true
	    send_mail true
	    client 
	    price 10000.0
	    provider_lock true
	    payed false
	    trx_id 
	    max_changes 2
	    token 
	    deal_id
	    booking_group
	    payed_booking_id
	    add_attribute :end, "2015-04-03 12:00:00"

	end

end