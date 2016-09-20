class CreatePaymentMethodTypes < ActiveRecord::Migration
  def change
    create_table :payment_method_types do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
