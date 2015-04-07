
FactoryGirl.define do

	factory :service_category do

		name		"Categoría de prueba"
		company 	#FactoryGirl.create(:company)
		order		0

	end
end
