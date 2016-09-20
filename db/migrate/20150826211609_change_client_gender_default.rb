class ChangeClientGenderDefault < ActiveRecord::Migration
  def up
    change_column_default(:clients, :gender, 0)
    change_column_null(:clients, :gender, false, 0)
  end

  def down
    change_column_default(:clients, :gender, nil)
    Client.connection.execute("UPDATE clients SET gender = NULL WHERE gender = 0")
  end
end
