module Filter
  module Clients
    module TypeClients
      def self.filter_by_search(clients, search)
        search_raw = search
        search_rut = search.gsub(/[.-]/, "")
        search_array = search.gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').split(' ')
        search_array2 = []
        search_array.each do |item|
          if item.length > 2
            search_array2.push('%'+item+'%')
          end
        end
        clients1 = clients.where('first_name ILIKE ANY ( array[:s] )', :s => search_array2).where('last_name ILIKE ANY ( array[:s] )', :s => search_array2).pluck(:id).uniq
        clients2 = clients.where("CONCAT(unaccent(first_name), ' ', unaccent(last_name)) ILIKE unaccent(:s) OR unaccent(first_name) ILIKE unaccent(:s) OR unaccent(last_name) ILIKE unaccent(:s) OR unaccent(record) ILIKE unaccent(:t) OR unaccent(email) ILIKE unaccent(:t) OR replace(replace(identification_number, '.', ''), '-', '') ILIKE :r", :s => "%#{search}%", :r => "%#{search_rut}%", :t => "%#{search_raw}%").pluck(:id).uniq
        clients.where(id: (clients1 + clients2).uniq)
      end

      def self.filter_by_gender(clients, gender)
        clients.where(gender: gender)
      end

      def self.filter_by_birthdate(clients, from, to)
        # Transformar string a date
        from = Date.parse(from)
        to = Date.parse(to)

        if from.month == to.month
          clients.where('birth_month = ? AND birth_day BETWEEN ? AND ?', from.month, from.day, to.day)
        elsif from.month < to.month
          clients.where('(birth_month = ? AND birth_day BETWEEN ? AND ?) OR (birth_month = ? AND birth_day BETWEEN ? AND ?) OR (birth_month > ? AND birth_month < ?)', from.month, from.day, 31, to.month, 1, to.day, from.month, to.month)
        elsif from.month > to.month
          clients.where('(birth_month = ? AND birth_day BETWEEN ? AND ?) OR (birth_month = ? AND birth_day BETWEEN ? AND ?) OR (birth_month > ? AND birth_month < ?) OR (birth_month > ? AND birth_month < ?)', from.month, from.day, 31, to.month, 1, to.day, from.month, 12, 1, to.month)
        end
      end
    end

    module TypeBookings
      def self.filter_by_status(clients, statuses)
        clients.where("bookings.status_id" => Status.find(statuses))
      end

      def self.filter_by_location(clients, locations)
        clients.where("bookings.location_id" => Location.find(locations))
      end

      def self.filter_by_provider(clients, providers)
        clients.where("bookings.service_provider_id" => ServiceProvider.find(providers))
      end

      def self.filter_by_service(clients, services)
        clients.where("bookings.service_id" => Service.find(services))
      end

      def self.filter_by_range(clients, from, to)
        # Transformar string a datetime
        from = Date.parse(from).to_datetime
        to = Date.parse(to).to_datetime

        clients.where('bookings.start BETWEEN ? AND ?', from.beginning_of_day, to.end_of_day)
      end
    end

    def self.filter_type_client(company_id, search, gender, birth_from, birth_to)
      clients = Client.from_company(company_id)
      clients = TypeClients::filter_by_search(clients, search) if search.present?
      clients = TypeClients::filter_by_gender(clients, gender) if gender.present?
      clients = TypeClients::filter_by_birthdate(clients, birth_from, birth_to) if birth_from.present? && birth_to.present?
      return clients
    end

    def self.filter_type_bookings(company_id, statuses, locations, providers, services, range_from, range_to, attendance)
      clients = Client.from_company(company_id).includes(:bookings)
      clients = TypeBookings::filter_by_status(clients, statuses) if statuses.present?
      clients = TypeBookings::filter_by_location(clients, locations) if locations.present?
      clients = TypeBookings::filter_by_provider(clients, providers) if providers.present?
      clients = TypeBookings::filter_by_service(clients, services) if services.present?
      clients = TypeBookings::filter_by_range(clients, range_from, range_to) if range_from.present? && range_to.present?

      if attendance == "false"
        clients = Client.from_company(company_id).includes(:bookings).where.not(id: clients.select(:id))
      end

      return clients
    end

    def self.filter(company_id, options = {})
      default_options = {
        search: "",
        attendance: true
      }
      options = default_options.merge(options)

      type_clients = self.filter_type_client(company_id, options[:search], options[:gender], options[:birth_from], options[:birth_to])
      type_bookings = self.filter_type_bookings(company_id, options[:statuses], options[:locations], options[:providers], options[:services], options[:range_from], options[:range_to], options[:attendance])

      Client.includes(:bookings).where(id: type_clients).where(id: type_bookings.select(:id))
    end
  end
end
