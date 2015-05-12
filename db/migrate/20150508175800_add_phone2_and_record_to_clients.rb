class AddPhone2AndRecordToClients < ActiveRecord::Migration
  def change
    add_column :clients, :record, :string
    add_column :clients, :second_phone, :string
  end
end
