class RemoveBookLimitDateFromTreatmentPromo < ActiveRecord::Migration
  def change
  	remove_column :treatment_promos, :book_limit_date, :datetime
  end
end
