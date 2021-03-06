class CompanySetting < ActiveRecord::Base
	belongs_to :company
	has_one :online_cancelation_policy
	has_many :payment_method_settings
	has_many :payment_methods, through: :payment_method_settings
	belongs_to :bank
	has_one :promo_time

	accepts_nested_attributes_for :online_cancelation_policy
	accepts_nested_attributes_for :promo_time

	accepts_nested_attributes_for :payment_method_settings, :reject_if => :all_blank, :allow_destroy => true

	#validates :email, :sms, :presence => true
	validate after_commit :extended_schedule
	after_update :check_payment_accounts

	after_create :build_payment_settings

	DATATYPES = [['Numérico', 'integer'], ['Decimal', 'float'], ['Texto', 'text'], ['Área de texto','textarea'], ['Binario (Sí/No)', 'boolean'], ['Fecha', 'date'], ['Fecha y hora', 'datetime'], ['Categórico', 'categoric'], ['Archivo', 'file']]

	def extended_schedule
		if self.extended_min_hour >= self.extended_max_hour
			errors.add(:base, "La hora de fin es menor o igual a la hora de inicio, para el horario extendido.")
		end
		location_ids = self.company.locations.pluck(:id)
		first_open_time = LocationTime.where(location_id: location_ids).order(:open).first.open
		last_close_time = LocationTime.where(location_id: location_ids).order(:close).last.close
		if self.extended_min_hour > first_open_time
			errors.add(:base, "La hora de inicio debe ser es menor o igual a la hora de apertura de todas las sucursales.")
		end
		if self.extended_max_hour < last_close_time
			errors.add(:base, "La hora de fin debe ser es mayor o igual a la hora de cierre de todas las sucursales.")
		end
	end

	def self.monthly_mails
		all.each do |setting|
			setting.monthly_mails  = 0
			setting.save
		end
	end

	def check_payment_accounts
		self.company.payment_accounts.each do |payment_account|
			payment_account.name = self.account_name
			payment_account.rut = self.company_rut
			payment_account.number = self.account_number
			payment_account.bank_code = self.bank.code
			payment_account.account_type = self.account_type
			payment_account.save
		end
	end

	def build_payment_settings
		PaymentMethod.all.each do |payment_method|
			if PaymentMethodSetting.where(company_setting_id: self.id, payment_method_id: payment_method.id).count < 1
				number_required = payment_method.name == 'Efectivo' || payment_method.name == 'Otro' ? false : true
				PaymentMethodSetting.create(company_setting_id: self.id, payment_method_id: payment_method.id, active: true, number_required: number_required)
			end
		end
	end

	def get_mails_capacity
		return self.mails_base_capacity * self.company.locations.where(active: true).count
	end

end
