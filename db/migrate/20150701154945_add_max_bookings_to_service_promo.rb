class AddMaxBookingsToServicePromo < ActiveRecord::Migration
  def change
  	add_column :service_promos, :max_bookings, :integer, default: 0
  end
end
