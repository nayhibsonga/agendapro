class SearchsController < ApplicationController
	layout "search"

	def index
		@districts = District.all
	end

	def search
		@districts = District.all
		@results = Hash.new

		#Locations
			# locals q coincidan el nombre
			# locals q coincidan el nombre del servicio
		locals = Location.where('district_id = ? AND name ILIKE ?', params[:district], '%' + params[:inputSearch] + '%')
		@results['locals'] = locals

		#Services
			# locales cuyos servicios q coincidan con el tag
		tags = Tag.where('name ILIKE ?', params[:inputSearch])
	end
end
