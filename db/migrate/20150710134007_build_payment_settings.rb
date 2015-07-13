class BuildPaymentSettings < ActiveRecord::Migration
	CompanySetting.all.each do |company_setting|
  		PaymentMethod.all.each do |payment_method|
			if PaymentMethodSetting.where(company_setting_id: company_setting.id, payment_method_id: payment_method.id).count < 1
				number_required = payment_method.name == 'Efectivo' || payment_method.name == 'Otro' ? false : true
				PaymentMethodSetting.create(company_setting_id: company_setting.id, payment_method_id: payment_method.id, active: true, number_required: number_required)
			end
		end
	end
end
