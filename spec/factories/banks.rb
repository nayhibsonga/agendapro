FactoryGirl.define do
	factory :bank do

		name	"Banco correcto"
		code	1

		trait :bank_otro do
			name	"Banco otro"
			code	0
		end

	end
end