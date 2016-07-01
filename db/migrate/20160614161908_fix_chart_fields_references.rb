class FixChartFieldsReferences < ActiveRecord::Migration
  def change
  	remove_column :chart_field_booleans, :charts_id
  	remove_column :chart_field_categorics, :charts_id
  	remove_column :chart_field_dates, :charts_id
  	remove_column :chart_field_datetimes, :charts_id
  	remove_column :chart_field_files, :charts_id
  	remove_column :chart_field_floats, :charts_id
  	remove_column :chart_field_integers, :charts_id
  	remove_column :chart_field_texts, :charts_id
  	remove_column :chart_field_textareas, :charts_id

  	add_reference :chart_field_booleans, :chart, index: true
  	add_reference :chart_field_categorics, :chart, index: true
  	add_reference :chart_field_dates, :chart, index: true
  	add_reference :chart_field_datetimes, :chart, index: true
  	add_reference :chart_field_files, :chart, index: true
  	add_reference :chart_field_floats, :chart, index: true
  	add_reference :chart_field_integers, :chart, index: true
  	add_reference :chart_field_texts, :chart, index: true
  	add_reference :chart_field_textareas, :chart, index: true
  end
end
