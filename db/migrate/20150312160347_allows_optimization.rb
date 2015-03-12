class AllowsOptimization < ActiveRecord::Migration
  def change
  	add_column :company_settings, :allows_optimization, :boolean, default: true
  end
end
