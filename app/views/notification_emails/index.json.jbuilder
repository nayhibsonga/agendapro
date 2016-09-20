json.array!(@notification_emails) do |notification_email|
  json.extract! notification_email, :id, :company_id, :emails, :notification_type, :receptor_type
  json.url notification_email_url(notification_email, format: :json)
end
