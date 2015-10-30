FactoryGirl.define do
  factory :petty_transaction do
    petty_cash_id 1
transactioner_id 1
transactioner_type 1
date "2015-10-08 13:01:40"
amount 1.5
is_income false
  end

end
