FactoryGirl.define do
  factory :billing_wire_transfer do
    payment_date "2015-11-16 12:07:20"
	amount 1.5
	receipt_number "MyString"
	account_name "MyString"
	account_bank "MyString"
	account_number "MyString"
	approved false
  end

end
