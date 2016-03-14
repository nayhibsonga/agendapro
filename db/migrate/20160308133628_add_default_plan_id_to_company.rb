class AddDefaultPlanIdToCompany < ActiveRecord::Migration
  def change

  	plan_normal = Plan.where(custom: false, name: "Normal").first

  	add_column :companies, :default_plan_id, :integer, default: plan_normal.id

  end

end