# spec/factories/users.rb

FactoryGirl.define do
  factory :vehicle do
    model   'Prius'
    make    'Toyota'
    year    2014
    style   'Car'

    trait :truck do
      model  'F-150'
      make   'Ford'
      style  'Truck'
    end

    trait :suv do
      model  'Escalade'
      make   'Cadilac'
      style  'SUV'
    end
  end
end