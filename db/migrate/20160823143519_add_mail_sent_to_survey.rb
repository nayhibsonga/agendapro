class AddMailSentToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :mail_sent, :boolean
  end
end
