class CreateEmailSendings < ActiveRecord::Migration
  def change
    create_table :email_sendings do |t|
      t.references :sendable, polymorphic: true
      t.datetime :send_date
      t.datetime :sent_date
      t.string :status, default: 'pending'

      t.timestamps
    end
  end
end
