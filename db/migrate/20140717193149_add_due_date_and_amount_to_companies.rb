class AddDueDateAndAmountToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :due_amount, :float, default: 0
    add_column :companies, :due_date, :date
  end
end
