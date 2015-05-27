FactoryGirl.define do
  factory :payment do
    company nil
amount 1.5
receipt_type nil
receipt_number "MyString"
payment_method nil
payment_method_number "MyString"
payment_method_type nil
installments 1
payed false
payment_date "2015-05-27"
bank nil
  end

end
