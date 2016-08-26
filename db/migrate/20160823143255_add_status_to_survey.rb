class AddStatusToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :status, :string
  end
end
