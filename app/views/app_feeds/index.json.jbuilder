json.array!(@app_feeds) do |app_feed|
  json.extract! app_feed, :id, :title, :company_id
end
