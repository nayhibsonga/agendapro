class CreatePaymentMethods < ActiveRecord::Migration
  def change
    create_table :payment_methods do |t|
      t.string :name, null: false

      t.timestamps
    end

    PaymentMethod.create(name: 'Efectivo')
    PaymentMethod.create(name: 'Tarjeta de Crédito')
    PaymentMethod.create(name: 'Tarjeta de Débito')
    PaymentMethod.create(name: 'Chaque')
    PaymentMethod.create(name: 'Otro')
  end
end
