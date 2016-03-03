class CompanyFromEmailWorker

  def self.perform(email_id)
    email = CompanyFromEmail.find(email_id)
    company = email.company

    CompanyFromEmailMailer.delay.confirm_email(email, company)
  end

end
