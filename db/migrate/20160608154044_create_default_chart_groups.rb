class CreateDefaultChartGroups < ActiveRecord::Migration
  def change
    Company.all.each do |company|
    	if ChartGroup.where(company_id: company.id, name: "Otros").count == 0
    		ChartGroup.create(company_id: company.id, name: "Otros", order: 1)
    	end
    end
  end
end
