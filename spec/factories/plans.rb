FactoryGirl.define do

    factory :plan do

    	name 					"Personal"
    	locations				1 
    	service_providers		1 
    	custom					false 
    	special					false 
    	monthly_mails			5000

    	trait :plan_basico do
    		name				"Básico"
		    locations 			1
		    service_providers 	30
		    custom 				false
		    special 			false
		    monthly_mails		5000
    	end

    	trait :plan_beta do
    		name				"Beta"
		    locations 			1
		    service_providers 	2
		    custom 				true
		    special 			false
		    monthly_mails		5000
    	end

    	trait :plan_premium do
    		name				"Premium"
		    locations 			3
		    service_providers 	90
		    custom 				false
		    special 			false
		    monthly_mails		15000
    	end

    	trait :plan_trial do
    		name				"Trial"
		    locations 			5
		    service_providers 	90
		    custom 				true
		    special 			false
		    monthly_mails		495000
    	end

    	trait :plan_normal do
    		name				"Normal"
		    locations 			2
		    service_providers 	60
		    custom 				false
		    special 			true
		    monthly_mails		10000
    	end

    end

end






