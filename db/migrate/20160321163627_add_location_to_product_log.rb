class AddLocationToProductLog < ActiveRecord::Migration
  def change
    add_reference :product_logs, :location, index: true, foreign_key: true
    add_reference :product_logs, :user, index: true, foreign_key: true
  end
end
