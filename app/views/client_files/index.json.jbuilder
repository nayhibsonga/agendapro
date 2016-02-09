json.array!(@client_files) do |client_file|
  json.extract! client_file, :id, :client_id, :name, :full_path, :public_url, :size, :description
  json.url client_file_url(client_file, format: :json)
end
