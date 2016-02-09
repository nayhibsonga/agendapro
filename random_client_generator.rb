#!/usr/bin/env ruby

# Parameters
# company: the ID of the company where the clients belongs.
# amount: the amount of client to generate. Default 100.
# gender: the gender of the clients generated. Default random.

# Example execution:
# load '/path_to/random_booking_generator.rb'
#
# random_client_generator(1, 300, 2)
#

def random_client_generator(company, amount=100, gender=nil)
  forenames = ["Nicolas", "Francisco", "Isabel", "Maria", "Paz", "Trinidad", "Sebastian", "Rodrigo", "Ignacio", "Rosario", "Jose", "Francisca", "Tomas", "Camila", "Montserrat", "Magdalena"]
  surnames = ["Flores", "Varela", "Rossi", "McAuliff", "Molina", "Volpi", "Del Pedregal", "Hevia", "Gomez", "Diaz", "Llona", "Mery", "Cambara", "Diez"]
  genders = [0, 1, 2]
  mail_domain = ["gmail", "hotmail", "outlook", "yahoo", "aol", "agendapro"]
  mail_extension = ["com", "cl", "co", "es"]
  mail_conector = [".", "-", "_", ""]

  amount.times do
    first_name = forenames.sample
    last_name = surnames.sample
    email = "#{first_name}#{mail_conector.sample}#{last_name}@#{mail_domain.sample}.#{mail_extension.sample}".downcase.gsub(' ', '')
    genre = gender.blank? ? genders.sample : gender
    birth = rand(80.year.ago..10.year.ago)

    c = Client.new(
      company_id: company,
      email: email,
      first_name: first_name,
      last_name: last_name,
      gender: genre,
      birth_day: birth.mday,
      birth_month: birth.mon,
      birth_year: birth.year
    )

    if c.save then puts "Cliente guardado" else puts c.errors.full_messages.inspect end
  end
end
