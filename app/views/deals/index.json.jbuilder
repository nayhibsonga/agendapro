json.array!(@deals) do |deal|
  json.extract! deal, :id, :code, :quantity, :active, :constraint_option, :constraint_quantity, :company_id_id
  json.url deal_url(deal, format: :json)
end
