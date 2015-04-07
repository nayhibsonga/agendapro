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
      #role          FactoryGirl.create(:role, :admin_role)
    end

    trait :general_admin do
      first_name    'General'
      last_name     'Admin'
      email         'generaladmin@agendapro.cl'
      phone         '+56993215098'
      #role          FactoryGirl.create(:role, :general_admin_role)
    end

    trait :super_admin do
      first_name    'Super'
      last_name     'Admin'
      email         'superadmin@agendapro.cl'
      phone         '+56993215098'
      #role          FactoryGirl.create(:role, :super_admin_role)
    end

  end
end