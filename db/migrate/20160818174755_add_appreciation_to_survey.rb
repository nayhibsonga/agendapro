class AddAppreciationToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :appreciation, :integer
  end
end
