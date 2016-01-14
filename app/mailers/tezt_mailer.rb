class TeztMailer < ActionMailer::Base
  default from: "idiez@agendapro.cl"

  def welcome
    mail(to: "idiez@agendapro.cl", subject: "TEEEZT", body: "Testing direct sending through Rails App")
  end

end
