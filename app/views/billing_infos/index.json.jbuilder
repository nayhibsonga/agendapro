json.array!(@billing_infos) do |billing_info|
  json.extract! billing_info, :id, :name, :rut, :address, :sector, :email, :phone, :company_id
  json.url billing_info_url(billing_info, format: :json)
end
