class CreateServiceTags < ActiveRecord::Migration
  def change
    create_table :service_tags do |t|
      t.references :service, index: true
      t.references :tag, index: true

      t.timestamps
    end
  end
end
