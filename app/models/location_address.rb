class LocationAddress
  attr_reader :street_number, :route, :district, :administrative_area, :city, :region, :country

  def initialize(args)
    @address = args || []
    @street_number = get_street_number
    @route = get_route
    @district = get_locality
    @administrative_area = get_administrative_area_level_3
    @city = get_administrative_area_level_2
    @region = get_administrative_area_level_1
    @country = get_country
  end

  private
    def get_street_number
      street_number = @address.select { |a| a.fetch("types", []).include? "street_number" }.first
      if street_number.present?
        street_number["long_name"]
      else
        ""
      end
    end

    def get_route
      route = @address.select { |a| a.fetch("types", []).include? "route" }.first
      if route.present?
        route["long_name"]
      else
        ""
      end
    end

    def get_locality
      locality = @address.select { |a| a.fetch("types", []).include? "locality" }.first
      if locality.present?
        locality["long_name"]
      else
        ""
      end
    end

    def get_administrative_area_level_3
      administrative_area_level_3 = @address.select { |a| a.fetch("types", []).include? "administrative_area_level_3" }.first
      if administrative_area_level_3.present?
        administrative_area_level_3["long_name"]
      else
        ""
      end
    end

    def get_administrative_area_level_2
      administrative_area_level_2 = @address.select { |a| a.fetch("types", []).include? "administrative_area_level_2" }.first
      if administrative_area_level_2.present?
        administrative_area_level_2["long_name"]
      else
        ""
      end
    end

    def get_administrative_area_level_1
      administrative_area_level_1 = @address.select { |a| a.fetch("types", []).include? "administrative_area_level_1" }.first
      if administrative_area_level_1.present?
        administrative_area_level_1["long_name"]
      else
        ""
      end
    end

    def get_country
      country = @address.select { |a| a.fetch("types", []).include? "country" }.first
      if country.present?
        country["long_name"]
      else
        ""
      end
    end
end
