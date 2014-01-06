class UserMailer < ActionMailer::Base
  default from: "agendapro@agendapro.cl"

  def welcome_email(user)
    @user = user
    @url  = 'http://www.agendapro.cl/login'
    mail(to: @user.email, subject: 'Bienvenido a AgendaPro')
  end
end
