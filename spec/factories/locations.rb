FactoryGirl.define do

    factory :location do
        name                            "Local"
        address                         "Elisa Cole 48"
        phone                           "+56993215098"
        latitude                        -33.4448416
        longitude                       -70.6332227
        district                        #FactoryGirl.create(:district)
        company                         #FactoryGirl.create(:company)
        active                          true
        order                           0
        outcall                         false
        email                           "iegomez@agendapro.cl"
        second_address                  nil
        online_booking                  true
    end
end