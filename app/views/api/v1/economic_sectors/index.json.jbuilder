json.array!(@economic_sectors) do |economic_sector|
  json.extract! economic_sector, :id, :name
  json.mobile_preview economic_sector.mobile_preview.url
end