class CreatePaymentMethodSettings < ActiveRecord::Migration
  def change
    create_table :payment_method_settings do |t|
      t.references :company_setting, index: true
      t.references :payment_method, index: true
      t.boolean :active, default: true
      t.boolean :number_required, default: true

      t.timestamps
    end
  end
end
