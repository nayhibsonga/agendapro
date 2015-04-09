FactoryGirl.define do
	
	factory :provider_time do

		open "2000-01-01 09:00:00"
    	close "2000-01-01 18:30:00"
    	service_provider
    	day

	end
end