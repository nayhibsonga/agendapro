class AdminMailer < Base::CustomMailer
  layout "mailers/green"

  def notify_promotion (service, recipient)
    @company = service.company

    # layout variables
    @title = "Creación o edición de promoción en #{@company.name}"
    @url = @company.web_url
    attacht_logo("public#{@company.logo.email.url}") unless @company.logo.email.url.include?("logo_vacio")

    # view variables
    @service = service
    @locations = ''
    location_ids = []

    if @service.active_service_promo.present?
      location_ids = location_ids + service.active_service_promo.promos.pluck(:location_id).uniq
    end
    if @service.active_last_minute_promo.present?
      location_ids = location_ids + service.active_last_minute_promo.locations.pluck(:id)
    end
    location_ids = location_ids.uniq
    location_ids.each do |l_id|
      location = Location.find(l_id)
      locations = locations + location.name + '<br />'
    end

    mail(
      from: filter_sender(),
      reply_to: filter_sender("nrossi@agendapro.cl"),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end
end
