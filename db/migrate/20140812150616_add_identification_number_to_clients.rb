class AddIdentificationNumberToClients < ActiveRecord::Migration
  def change
    add_column :clients, :identification_number, :string
  end
end
