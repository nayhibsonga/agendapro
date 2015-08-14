module Api
  module V1
  	class EconomicSectorsController < V1Controller
      def index
      	@locations = Location.where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true)
      	@economic_sectors = EconomicSector.where(show_in_home: true, id: CompanyEconomicSector.where(company_id: @locations.pluck(:company_id)).pluck(:economic_sector_id))
      end
  	end
  end
end