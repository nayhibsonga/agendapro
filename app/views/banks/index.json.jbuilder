json.array!(@banks) do |bank|
  json.extract! bank, :id, :code, :name
  json.url bank_url(bank, format: :json)
end
