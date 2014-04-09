json.array!(@clients) do |client|
  json.extract! client, :id, :company_id, :email, :first_name, :last_name, :address, :district, :city, :age, :gender, :birth_date
  json.url client_url(client, format: :json)
end
