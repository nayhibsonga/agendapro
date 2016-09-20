class CreateProviderBreakRepeats < ActiveRecord::Migration
  def change
    create_table :provider_break_repeats do |t|
      t.datetime :start_date
      t.datetime :end_date
      t.string :repeat_option
      t.string :repeat_type
      t.integer :times

      t.timestamps
    end
  end
end
