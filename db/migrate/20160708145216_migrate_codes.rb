class MigrateCodes < ActiveRecord::Migration
  def change
  	add_reference :payments, :employee_code, index: true
  	add_reference :internal_sales, :employee_code, index: true
  	add_reference :booking_histories, :employee_code, index: true

  	Payment.where.not(cashier_id: nil).each do |payment|
  		payment.update_column(:employee_code_id, payment.cashier_id)
  	end

  	InternalSale.all.each do |internal_sale|
  		internal_sale.update_column(:employee_code_id, internal_sale.cashier_id)
  	end

  	Cashier.all.each do |cashier|
  		employee_code = EmployeeCode.create(company_id: cashier.company_id, name: cashier.name, code: cashier.code, active: cashier.active, cashier: true, staff: false)
  		PaymentProduct.where(seller_type: 2, seller_id: cashier.id).update_all(seller_id: employee_code_id)
  		PettyTransaction.where(transactioner_type: 2, transactioner_id: cashier.id).update_all(transactioner_id: employee_code_id)
  		StaffCode.where(company_id: cashier.company_id, code: cashier.code).each do |staff_code|
  			employee_code.update_column(:staff, true)
  			BookingHistory.where(staff_code_id: staff_code.id).update_all(employee_code_id: staff_code_id, staff_code_id: nil)
  			staff_code.delete
  		end
  	end

  	StaffCode.all.each do |staff_code|
  		employee_code = EmployeeCode.create(company_id: staff_code.company_id, name: staff_code.name, code: staff_code.code, active: staff_code.active, cashier: false, staff: true)
  		BookingHistory.where(staff_code_id: staff_code.id).update_all(employee_code_id: staff_code_id, staff_code_id: nil)
  			staff_code.delete
  		end
  	end

  	remove_column :payments, :cashier_id, :integer
  	remove_column :internal_sales, :cashier_id, :integer
  	remove_column :booking_histories, :staff_code_id, :integer

  	#drop_table :cashiers
  	#drop_table :staff_codes

  end
end