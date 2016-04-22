class StockMailer < Base::CustomMailer
  layout "mailers/green"

  def alarm_stock(stock, recipient)
    @company = stock.location.company

    # layout variables
    @title = "Alerta de stock en #{stock.location.name}"
    @url = @company.web_url
    attacht_logo()

    # view variables
    @stock = stock
    @limit = @stock.stock_limit.present? ? @stock.stock_limit : @stock.location.stock_alarm_setting.default_stock_limit

    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  def reminder_stock(stock, recipient)
    @company = stock.company

    # layout variables
    @title = "Recordatorio de stock para #{stock.name}"
    @url = @company.web_url
    attacht_logo()

    # view variables
    @stock = stock

    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
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
