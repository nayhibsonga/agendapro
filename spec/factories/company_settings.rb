FactoryGirl.define do

    factory :company_setting do

    	signature ""
	    email  false
	    sms  false
	    company
	    before_booking  24
	    after_booking  6
	    before_edit_booking  3
	    activate_search  true
	    activate_workflow  true
	    client_exclusive  false
	    provider_preference nil
	    calendar_duration  15
	    extended_schedule_bool  false
	    extended_min_hour  "2000-01-01 09:00:00"
	    extended_max_hour  "2000-01-01 20:00:00"
	    schedule_overcapacity  true
	    provider_overcapacity  true
	    resource_overcapacity  true
	    booking_confirmation_time  1
	    booking_configuration_email  0
	    max_changes  2
	    booking_history  false
	    staff_code  false
	    monthly_mails  0
	    allows_online_payment  true
	    account_number  "123456789"
	    company_rut  "11.111.111-1"
	    account_name  "Nombre titular"
	    account_type  3
	    bank
	    deal_activate  false
	    deal_name  ""
	    deal_overcharge  true
	    deal_exclusive  false
	    deal_quantity  0
	    deal_constraint_option  0
	    deal_constraint_quantity  0
	    deal_identification_number  false
	    deal_required  false
	    online_payment_capable  true
	    allows_optimization  true

    end

end