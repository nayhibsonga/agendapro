class CreatePaymentStatuses < ActiveRecord::Migration
  def change
    create_table :payment_statuses do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
