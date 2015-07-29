class AddImagesToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :image1, :string
    add_column :locations, :image2, :string
    add_column :locations, :image3, :string
  end
end
