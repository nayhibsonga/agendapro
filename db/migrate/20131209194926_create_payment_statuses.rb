class CreatePaymentStatuses < ActiveRecord::Migration
  def change
    create_table :payment_statuses do |t|
      t.string :name, :null => false
      t.text :description, :null => false

      t.timestamps
    end
  end
end
