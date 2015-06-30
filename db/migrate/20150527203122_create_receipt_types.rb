class CreateReceiptTypes < ActiveRecord::Migration
  def change
    create_table :receipt_types do |t|
      t.string :name, null: false

      t.timestamps
    end

    ReceiptType.create('Boleta')
    ReceiptType.create('Factura')
    ReceiptType.create('Otro')
    ReceiptType.create('Boleta de Servicios')
  end
end
