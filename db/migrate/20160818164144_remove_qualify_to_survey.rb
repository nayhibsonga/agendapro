class RemoveQualifyToSurvey < ActiveRecord::Migration
  def change
    remove_column :surveys, :quality, :integer
    remove_column :surveys, :style, :integer
    remove_column :surveys, :satifaction, :integer
    remove_column :surveys, :comment, :text
    remove_reference :surveys, :booking, index: true
  end
end
