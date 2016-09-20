json.array!(@payments) do |payment|
  json.extract! payment, :id, :company_id, :amount, :receipt_type_id, :receipt_number, :payment_method_id, :payment_method_number, :payment_method_type_id, :installments, :payed, :payment_date, :bank_id
  json.url payment_url(payment, format: :json)
end
