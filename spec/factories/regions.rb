FactoryGirl.define do

    factory :region do
    	name		"XIII - Región Metropolitana"
    	country		#FactoryGirl.create(:country)
    end
    
end