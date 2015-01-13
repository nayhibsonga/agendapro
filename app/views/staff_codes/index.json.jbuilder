json.array!(@staff_codes) do |staff_code|
  json.extract! staff_code, :id
  json.url staff_code_url(staff_code, format: :json)
end
