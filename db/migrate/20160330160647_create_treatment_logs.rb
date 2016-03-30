class CreateTreatmentLogs < ActiveRecord::Migration
  def change
    create_table :treatment_logs do |t|
      t.references :client, index: true
      t.references :user, index: true
      t.references :service, index: true
      t.text :detail

      t.timestamps
    end
  end
end
