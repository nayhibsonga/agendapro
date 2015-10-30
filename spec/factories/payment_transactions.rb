FactoryGirl.define do
  factory :payment_transaction do
    payment_id 1
payment_method_id 1
company_payment_method_id 1
number "MyString"
amount 1.5
installments 1
payment_method_type_id 1
bank_id 1
  end

end
