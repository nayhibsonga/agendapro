class AddPublicDirectories < ActiveRecord::Migration
  def change
  	Dir.mkdir("#{Rails.root}/public/bookings_files")
  	Dir.mkdir("#{Rails.root}/public/payments_files")
  	Dir.mkdir("#{Rails.root}/public/products_files")
  	Dir.mkdir("#{Rails.root}/public/clients_files")
  end
end
