class AddLastModifierToCharts < ActiveRecord::Migration
  def change
  	add_reference :charts, :last_modifier, references: :users, index: true
  end
end
