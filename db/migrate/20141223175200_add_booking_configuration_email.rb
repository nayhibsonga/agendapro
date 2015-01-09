class AddBookingConfigurationEmail < ActiveRecord::Migration
	# Opciones
	# 0: Transacional
	# 1: Una vez al dia
	# 2: Utiliza la configuracion del padre
	# 3: No se manda email
  def change
  	add_column :company_settings, :booking_configuration_email, :integer, default: 0
  	add_column :locations, :booking_configuration_email, :integer, default: 0
  	add_column :service_providers, :booking_configuration_email, :integer, default: 0
  end
end
