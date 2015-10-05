class AddRoleAndCompanyStats < ActiveRecord::Migration
  def change
  	add_column :stats_companies, :last_payment, :datetime
  	add_column :stats_companies, :last_payment_method, :string
  	add_column :stats_companies, :company_payment_status_id, :integer

  	Role.create(name: "Ventas", description: "Rol Ejecutivo Comercial AgendaPro")
  end
end
