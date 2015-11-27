json.array!(@companies) do |company|
  json.id company.id
  json.name company.name
  json.url company.web_address + '.agendapro' + company.country.domain
  json.logo company.logo && company.logo.url ? request.protocol + request.host_with_port + company.logo.url : ""
end