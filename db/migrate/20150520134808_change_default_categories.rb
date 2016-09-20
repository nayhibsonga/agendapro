class ChangeDefaultCategories < ActiveRecord::Migration
  ServiceCategory.where(name: "Sin Categoría").each do |service_category|
  	service_category.name = "Otros"
  	if service_category.save
  		puts 'Se guarda service_category id ' + service_category.id.to_s + ' de empresa ' + service_category.company_id.to_s
  	else
  		puts 'ERROR id ' + service_category.id.to_s + ' de empresa ' + service_category.company_id.to_s + ' - ' + service_category.errors.full_messages.inspect
  	end
  end
  ResourceCategory.where(name: "Sin Categoría").each do |resource_category|
  	resource_category.name = "Otros"
  	if resource_category.save
  		puts 'Se guarda id ' + resource_category.id.to_s + ' de empresa ' + resource_category.company_id.to_s
  	else
  		puts 'ERROR id ' + resource_category.id.to_s + ' de empresa ' + resource_category.company_id.to_s + ' - ' + resource_category.errors.full_messages.inspect
  	end
  end
end
