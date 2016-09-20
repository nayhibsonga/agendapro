FactoryGirl.define do

	factory :status do

		name    'Reservado'
		description     'Reserva agendada'

		trait :status_confirmado do
			name 'Confirmado'
			description 'Reserva confirmada por el usuario'
	    end

	    trait :status_asiste do
			name 'Asiste'
			description 'Reserva completada con el cliente'
	    end

	end
end