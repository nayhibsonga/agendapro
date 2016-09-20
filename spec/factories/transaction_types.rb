FactoryGirl.define do

	factory :transaction_type do

		name		"Webpay"
		description	"El usuario paga por Webpay"

		trait :transaction_type_transferencia do
			name		"Transferencia"
			description	"El usuario paga por transferencia bancaria"
		end

		trait :transaction_type_otro do
			name		"Otra"
			description	"El usuario paga por otro medio"
		end

	end
end
