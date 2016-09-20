FactoryGirl.define do

    factory :city do
    	name		"Santiago"
    	region		#FactoryGirl.create(:region)
    end
    
end