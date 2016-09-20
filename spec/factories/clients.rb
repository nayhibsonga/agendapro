FactoryGirl.define do

  factory :client do
    first_name              'Normal'
    last_name               'Client'
    email                   'normalclient@agendapro.cl'
    phone                   '+56993215098'
    can_book                true
    company              
  end
end