json.array!(@companies) do |company|
  json.id company.id
  json.name company.name
  json.url company.web_address + '.agendapro' + company.country.domain
  json.logo company.logo && company.logo.page && company.logo.page.url && company.logo.page.url != "/assets/logo_vacio.png" ? request.protocol + request.host_with_port + company.logo.page.url : request.protocol + request.host_with_port + "/assets/default_marketplace.png"
end