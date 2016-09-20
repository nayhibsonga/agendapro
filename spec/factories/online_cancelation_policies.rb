FactoryGirl.define do
	factory :online_cancelation_policy do
		cancelable			false
		modifiable			false
		cancel_max			32
		modification_max	3
		min_hours			32
		modification_unit	4
		cancel_unit			2
		company_setting		
	end
end