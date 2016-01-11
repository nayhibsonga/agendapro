module Api
  module Agendapro
  module V1
  	class EconomicSectorsController < V1Controller
      def index
        if params[:latitude].present? && params[:longitude].present?
          @locations = Location.where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + params[:latitude] + ')^2 + (longitude - ' + params[:longitude] + ')^2) < 0.25')
        else
          @locations = Location.where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true)
        end
      	@economic_sectors = EconomicSector.select('economic_sectors.id, economic_sectors.name, economic_sectors.mobile_preview, count(company_economic_sectors.id) AS companies_count').joins(:company_economic_sectors).where(company_economic_sectors: { company_id: @locations.pluck(:company_id).uniq } ).group('economic_sectors.id').having('count(company_economic_sectors.id) > ?', 0).order('companies_count DESC')
      	# @economic_sectors = EconomicSector.where( show_in_home: true, id: CompanyEconomicSector.where(company_id: @locations.pluck(:company_id)).pluck(:economic_sector_id) )
      end
  	end
  end
end
end
