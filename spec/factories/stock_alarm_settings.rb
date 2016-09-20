FactoryGirl.define do
  factory :stock_alarm_setting do
    location_id 1
quick_send false
has_default_stock_limit false
default_stock_limit 1
monthly false
month_day 1
week_day 1
  end

end
