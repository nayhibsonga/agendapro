json.array!(@economic_sectors) do |economic_sector|
  json.extract! economic_sector, :id, :name
  json.mobile_preview location.mobile_preview && location.mobile_preview && location.mobile_preview.url ? request.protocol + request.host_with_port + location.mobile_preview.url : ""
end