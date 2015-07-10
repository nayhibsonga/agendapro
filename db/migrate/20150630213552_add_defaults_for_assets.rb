class AddDefaultsForAssets < ActiveRecord::Migration
    ReceiptType.create(name: 'Boleta') if ReceiptType.where(name: 'Boleta').count < 1
    ReceiptType.create(name: 'Factura') if ReceiptType.where(name: 'Factura').count < 1
    ReceiptType.create(name: 'Otro') if ReceiptType.where(name: 'Otro').count < 1
    ReceiptType.create(name: 'Boleta de Servicios') if ReceiptType.where(name: 'Boleta de Servicios').count < 1

    PaymentMethod.create(name: 'Efectivo') if PaymentMethod.where(name: 'Efectivo').count < 1
    PaymentMethod.create(name: 'Tarjeta de Crédito') if PaymentMethod.where(name: 'Tarjeta de Crédito').count < 1
    PaymentMethod.create(name: 'Tarjeta de Débito') if PaymentMethod.where(name: 'Tarjeta de Débito').count < 1
    PaymentMethod.create(name: 'Cheque') if PaymentMethod.where(name: 'Cheque').count < 1
    PaymentMethod.create(name: 'Otro') if PaymentMethod.where(name: 'Otro').count < 1
end
