class CreateEmailExclusions < ActiveRecord::Migration
  def change
    create_table :email_exclusions do |t|
      t.string :domain
      t.boolean :status

      t.timestamps
    end
  end
end
