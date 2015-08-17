FactoryGirl.define do

	factory :booking do

		start	"2015-08-20 11:15:00"
	    notes "Bla bla bla"
	    service_provider #FactoryGirl.create(:service_provider)
	    user_id nil
	    service #FactoryGirl.create(:service)
	    location #FactoryGirl.create(:location)
	    status #FactoryGirl.create(:status)
	    promotion_id nil
	    created_at "2015-03-31 14:41:46"
	    updated_at "2015-03-31 14:42:34"
	    company_comment ""
	    web_origin true
	    send_mail true
	    client 
	    price 10000.0
	    provider_lock true
	    payed false
	    trx_id ""
	    max_changes 2
	    token ""
	    deal_id nil
	    booking_group nil
	    payed_booking_id nil
	    is_session false
	    session_booking_id nil
	    user_session_confirmed false
	    is_session_booked false
	    service_promo_id nil
	    payment_id nil
	    discount 0.0
	    add_attribute :end, "2015-08-20 12:00:00"

	end

end