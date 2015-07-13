FactoryGirl.define do
	factory :payment_method do
		name    'Efectivo'

		trait :debit_card do
			name 'Tarjeta de Débito'
	    end

	    trait :credit_card do
			name 'Tarjeta de Crédito'
	    end

	    trait :check do
			name 'Cheque'
	    end

	end
end