json.array!(@economic_sectors_dictionaries) do |economic_sectors_dictionary|
  json.extract! economic_sectors_dictionary, :id, :name, :economic_sector_id
  json.url economic_sectors_dictionary_url(economic_sectors_dictionary, format: :json)
end
