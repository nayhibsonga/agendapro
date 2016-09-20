FactoryGirl.define do
  factory :fake_payment do
    company_id 1
amount 1.5
receipt_type_id 1
receipt_number "MyString"
payment_method_id 1
payment_method_number "MyString"
payment_method_type_id 1
installments 1
payed false
payment_date "2015-10-30"
bank_id 1
created_at "2015-10-30 19:45:03"
updated_at "2015-10-30 19:45:03"
company_payment_method_id 1
discount 1.5
notes "MyText"
location_id 1
client_id 1
bookings_amount 1.5
bookings_discount 1.5
products_amount 1.5
products_discount 1.5
products_quantity 1
bookings_quantity 1
quantity 1
sessions_amount 1.5
sessions_discount 1.5
sessions_quantity 1
  end

end
