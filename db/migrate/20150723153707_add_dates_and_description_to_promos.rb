class AddDatesAndDescriptionToPromos < ActiveRecord::Migration
  def change
  	add_column :service_promos, :finish_date, :datetime, default: "2016-01-01 09:00:00"
  	add_column :service_promos, :book_limit_date, :datetime, default: "2016-01-01 09:00:00"
  	add_column :service_promos, :limit_booking, :boolean, default: true
  	add_column :services, :promo_description, :text, default: ""
  end
end
