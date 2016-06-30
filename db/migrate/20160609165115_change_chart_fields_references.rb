class ChangeChartFieldsReferences < ActiveRecord::Migration
  def change
  	remove_column :chart_field_booleans, :client_id
  	remove_column :chart_field_categorics, :client_id
  	remove_column :chart_field_dates, :client_id
  	remove_column :chart_field_datetimes, :client_id
  	remove_column :chart_field_files, :client_id
  	remove_column :chart_field_floats, :client_id
  	remove_column :chart_field_integers, :client_id
  	remove_column :chart_field_texts, :client_id
  	remove_column :chart_field_textareas, :client_id

  	add_reference :chart_field_booleans, :charts, index: true
  	add_reference :chart_field_categorics, :charts, index: true
  	add_reference :chart_field_dates, :charts, index: true
  	add_reference :chart_field_datetimes, :charts, index: true
  	add_reference :chart_field_files, :charts, index: true
  	add_reference :chart_field_floats, :charts, index: true
  	add_reference :chart_field_integers, :charts, index: true
  	add_reference :chart_field_texts, :charts, index: true
  	add_reference :chart_field_textareas, :charts, index: true
  end
end
