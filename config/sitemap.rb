# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://#{ENV['DEFAULT_URL_OPTIONS']}"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  add home_path, :priority => 1
  add features_path, :priority => 0.9
  add view_plans_path, :priority => 0.8
  add '/', :host => "http://blog.#{ENV['DEFAULT_URL_OPTIONS']}", :priority => 0.7
  add contact_path, :priority => 0.6
  add tutorials_path, :priority => 0.5
  add localized_search_path, :priority => 0.4



  Company.where(id: CompanySetting.where(activate_search: true, activate_workflow: true).pluck(:company_id), payment_status_id: [PaymentStatus.find_by_name("Activo"), PaymentStatus.find_by_name("Convenio PAC"), PaymentStatus.find_by_name("Emitido"), PaymentStatus.find_by_name("Vencido")], owned: true).each do |company|
    add "/#{company.country.locale}", :host => "http://#{company.web_address}.#{ENV['DEFAULT_URL_OPTIONS']}", :priority => 0.3
  end

end
