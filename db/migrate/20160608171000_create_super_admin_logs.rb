class CreateSuperAdminLogs < ActiveRecord::Migration
  def change
    create_table :super_admin_logs do |t|
      t.references :company, index: true
      t.references :user, index: true
      t.text :detail

      t.timestamps
    end
  end
end
