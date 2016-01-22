FactoryGirl.define do
  factory :payment do
	company
	amount 1.5
	receipt_type
	receipt_number "0123456789"
	payment_method
	payment_method_number "0123456789"
	payment_method_type
	installments 1
	payed false
	payment_date "2015-05-27"
	bank
  end

end
