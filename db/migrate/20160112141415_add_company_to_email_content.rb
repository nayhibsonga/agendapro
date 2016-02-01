class AddCompanyToEmailContent < ActiveRecord::Migration
  def change
    add_reference :email_contents, :company, index: true
  end
end
