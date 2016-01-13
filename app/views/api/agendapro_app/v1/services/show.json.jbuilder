json.extract! @service, :id, :name, :description, :duration, :price
json.service_category @service.service_category.name