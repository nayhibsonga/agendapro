json.array!(@economic_sectors) do |economic_sector|
  json.extract! economic_sector, :id
  json.url economic_sector_url(economic_sector, format: :json)
end
