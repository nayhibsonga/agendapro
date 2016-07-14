class CreateCharts < ActiveRecord::Migration
  def change
    create_table :charts do |t|
      t.references :company, index: true
      t.references :client, index: true
      t.references :booking, index: true
      t.references :user, index: true
      t.timestamp :date

      t.timestamps
    end
  end
end
