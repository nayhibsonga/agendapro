json.array!(@economic_sectors) do |economic_sector|
  json.extract! economic_sector, :id, :name
end