FactoryGirl.define do
  factory :sales_transaction do
    sales_cash_id 1
transactioner_id 1
transactioner_type 1
date "2015-10-21 10:41:38"
amount 1.5
is_income false
notes "MyText"
receipt_number "MyString"
  end

end
