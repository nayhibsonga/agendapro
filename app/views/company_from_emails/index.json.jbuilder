json.array!(@company_from_emails) do |company_from_email|
  json.extract! company_from_email, :id, :email, :company_id
  json.url company_from_email_url(company_from_email, format: :json)
end
