class ClientsBasePdf < Prawn::Document
	def initialize(company_id)

		font_families.update(
			"Roboto" => {
				normal: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Light.ttf')}", font: 'Roboto Condensed Light'},
				bold: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Bold.ttf')}", font: 'Roboto Condensed Bold'}
			}
		)
		super()
		font 'Roboto'

		@company = Company.find(company_id)
		header(@company)		

	end

	def header(company)

		y_position = cursor
		bounding_box([220, y_position], width: 260, height: 30) do
			text "<b>" + company.name + "</b>",
				:inline_format => true
		end

		move_down 10

		info_rows = []

		info_rows << ["A continuación se detallan las opciones para la importación de clientes. Debes respetar los formatos indicados o los clientes no se importarán de manera correcta."]

		move_down 10

		info_rows << ["email: ", "Email del cliente. Debe ser único."]
		info_rows << ["first_name", "Nombres del cliente."]
		info_rows << ["last_name", "Apellidos del cliente."]
		info_rows << ["identification_number"]

		info_rows = [["email", "Email del cliente. Debe ser único."], ["first_name", "Nombres del cliente."], ["last_name", "Apellidos del cliente."], ["identification_number", "Rut o CI del cliente. Debe ser único."], ["record", "Número de cliente. Puede ser un número o una palabra seguida de un número."], ["phone", "Teléfono principal del cliente."], ["second_phone", "Teléfono secundario del cliente (oficina, casa, etc.)."], ["address", "Dirección del cliente."], ["district", "Comuna de residencia."], ["city", "Ciudad de residencia."], ["age", "Edad del cliente."], ["gender", "Género del cliente. 1 si es mujer, 2 es hombre, 0 si no se desea definir."], ["birth_day", "Día del cumpleaños, sin fecha. Del 1 al 31."], ["birth_month", "Mes del cumpleaños, sin fecha. Del 1 al 12."], ["birth_year", "Año de nacimiento."]]


		company.custom_attributes.each do |attribute|
			if attribute.datatype != "file"
				if attribute.datatype != "categoric"
					info_rows << [attribute.slug, attribute.datatype_to_text + ": " + attribute.description]
				else
					categories = attribute.attribute_categories.pluck(:category).join(", ")
					info_rows << [attribute.slug, attribute.datatype_to_text + ": " + attribute.description + ". Categorías: " + categories]
				end
			end
		end

		table(info_rows) do
			cells.borders = []
		end

		move_down 10

	end

end
