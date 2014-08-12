class AddCanBookToClients < ActiveRecord::Migration
  def change
    add_column :clients, :can_book, :boolean, default: true
  end
end
