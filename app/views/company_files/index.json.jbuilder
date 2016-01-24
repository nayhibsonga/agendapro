json.array!(@company_files) do |company_file|
  json.extract! company_file, :id, :company_id, :name, :full_path, :public_url, :size, :description
  json.url company_file_url(company_file, format: :json)
end
