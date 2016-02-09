class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.string :name
      t.string :source
      t.string :thumb
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
