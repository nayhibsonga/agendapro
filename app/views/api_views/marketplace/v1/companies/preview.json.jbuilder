json.array!(@companies) do |company|
  json.id company.id
  json.name company.name
  json.url company.web_address + '.agendapro' + company.country.domain
  json.logo company.logo.url
end