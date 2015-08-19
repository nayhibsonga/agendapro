FactoryGirl.define do

    factory :district do
    	name		"Santiago"
    	city		#FactoryGirl.create(:city)
    end
    
end