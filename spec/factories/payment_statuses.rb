FactoryGirl.define do

    factory :payment_status do
	
		name 			"Activo"
		description 	"La empresa tiene todos los pagos al día"

		trait :vencido do
			name 			"Vencido"
  			description 	"La empresa está atrasada en el pago del mes en curso"
		end

		trait :trial do
			name 			"Trial"
  			description 	"La empresa está en período de prueba"
		end

		trait :bloqueado do
			name 			"Bloqueado"
  			description 	"La empresa está bloqueada por no pago de plan"
		end

		trait :emitido do
			name 			"Emitido"
  			description 	"La empresa tiene un pago emitido vigente"
		end

		trait :inactivo do
			name 			"Inactivo"
  			description 	"La empresa está inactiva por no uso/pago"
		end

		trait :admin do
			name 			"Admin"
  			description 	"Para empresas que agreguemos nosotros"
		end

	end

end