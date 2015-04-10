FactoryGirl.define do
	factory :role do
		name    'Usuario Registrado'
		description     'Usuario con cuenta registrada y accesible'

		trait :admin_role do
			name 'Administrador Local'
			description 'Administrador de local'
	    end

	    trait :general_admin_role do
			name 'Administrador General'
			description 'Administrador de empresa inscrita en AgendaPro'
	    end

	    trait :super_admin_role do
			name 'Super Admin'
			description 'Administrador de la aplicaión AgendaPro'
	    end

	    trait :staff_role do
	    	name 'Staff'
			description 'Usuario con atribuciones de atención en su local'
	    end

	    trait :unregistered_role do
	    	name 'Usuario No Registrado'
			description 'Usuario con cuenta no registrada'
	    end

	    trait :recepcionista_role do
	    	name 'Recepcionista'
			description 'Usuario frontdesk de una empresa'
	    end

	    trait :staff_uneditable_role do
	    	name 'Staff (sin edición)'
			description 'asd'
	    end

	end
end