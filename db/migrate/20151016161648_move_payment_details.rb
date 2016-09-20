class MovePaymentDetails < ActiveRecord::Migration
  def change
  	remove_column :payments, :payment_method_id, :integer
  	remove_column :payments, :payment_method_number, :string
  	remove_column :payments, :payment_method_type_id, :integer
  	remove_column :payments, :installments, :integer
  	remove_column :payments, :bank_id, :integer
  	remove_column :payments, :company_payment_method_id, :integer
  end
end
