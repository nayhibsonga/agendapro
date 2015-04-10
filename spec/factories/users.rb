# spec/factories/users.rb

FactoryGirl.define do

  factory :user do
    first_name              'Normal'
    last_name               'User'
    email                   'normaluser@agendapro.cl'
    phone                   '+56993215098'
    password                'password'
    password_confirmation   'password'
    role                    

    trait :admin do
      first_name    'Admin'
      last_name     'Admin'
      email         'admin@agendapro.cl'
      phone         '+56993215098'
    end

    trait :general_admin do
      first_name    'General'
      last_name     'Admin'
      email         'generaladmin@agendapro.cl'
      phone         '+56993215098'
    end

    trait :super_admin do
      first_name    'Super'
      last_name     'Admin'
      email         'superadmin@agendapro.cl'
      phone         '+56993215098'
    end

  end
end