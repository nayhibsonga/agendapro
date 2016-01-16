class AddSlugToAttribute < ActiveRecord::Migration
  def change
  	add_column :attributes, :slug, :string, default: ""
  end
end
