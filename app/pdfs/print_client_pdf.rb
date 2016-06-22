class PrintClientPdf < Prawn::Document
	def initialize(client_id)

		font_families.update(
			"Roboto" => {
				normal: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Light.ttf')}", font: 'Roboto Condensed Light'},
				bold: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Bold.ttf')}", font: 'Roboto Condensed Bold'}
			}
		)
		super()
		font 'Roboto'

		@client = Client.find(client_id)
		@company = @client.company
		header(@client, @company)		

	end

	def header(client, company)

		y_position = cursor
		bounding_box([220, y_position], width: 260, height: 30) do
			text "<b>" + client.full_name + "</b>",
				:inline_format => true
		end

		info_rows = []

		info_rows << ["Datos personales:"]
    info_rows << [""]
    info_rows << [""]

		move_down 20

		info_rows << ["Email", "#{client.email}"]
		info_rows << ["Nombre(s)", "#{client.first_name}"]
		info_rows << ["Apellido(s)", "#{client.last_name}"]
		info_rows << ["C.I.", "#{client.identification_number}"]
		info_rows << ["Número de cliente", "#{client.record}"]
		info_rows << ["Teléfono", "#{client.phone}"]
		info_rows << ["Teléfono secundario", "#{client.second_phone}"]
		info_rows << ["Dirección", "#{client.address}"]
		info_rows << ["Comuna", "#{client.district}"]
		info_rows << ["Ciudad", "#{client.city}"]
		info_rows << ["Edad", "#{client.age}"]
		info_rows << ["Fecha de nacimiento", "#{client.get_birth_date}"]
		if client.gender == 1
			info_rows << ["Género", "Femenino"]
		elsif client.gender == 2
			info_rows << ["Género", "Masculino"]
		else
			info_rows << ["Edad", "No ingresado"]
		end
		info_rows << ["Fecha de ingreso", (client.created_at + company.country.timezone_offset.hours).strftime("%d/%m/%Y %R")]

		move_down 20
    info_rows << [""]
    info_rows << [""]

		company.attribute_groups.order(:order).each do |attribute_group|

			info_rows << [attribute_group.name + ":"]

			move_down 20
      info_rows << [""]
      info_rows << [""]

			attribute_group.custom_attributes.order(:order).each do |attribute|

				case attribute.datatype
        when "float"

          float_attribute = FloatAttribute.where(attribute_id: attribute.id, client_id: client.id).first
          if !float_attribute.nil? && !float_attribute.value.nil?
            info_rows << [attribute.name, float_attribute.value]
          else
            info_rows << [attribute.name, ""]
          end

        when "integer"

          integer_attribute = IntegerAttribute.where(attribute_id: attribute.id, client_id: client.id).first
          if !integer_attribute.nil? && !integer_attribute.value.nil?
            info_rows << [attribute.name, integer_attribute.value]
          else
            info_rows << [attribute.name, ""]
          end

        when "text"

          text_attribute = TextAttribute.where(attribute_id: attribute.id, client_id: client.id).first
          if !text_attribute.nil? && !text_attribute.value.nil?
            info_rows << [attribute.name, text_attribute.value]
          else
            cinfo_rows << [attribute.name, ""]
          end

        when "textarea"

          textarea_attribute = TextareaAttribute.where(attribute_id: attribute.id, client_id: client.id).first
          if !textarea_attribute.nil? && !textarea_attribute.value.nil?
            info_rows << [attribute.name, textarea_attribute.value]
          else
            info_rows << [attribute.name, ""]
          end

        when "boolean"

          boolean_attribute = BooleanAttribute.where(attribute_id: attribute.id, client_id: client.id).first
          if !boolean_attribute.nil? && !boolean_attribute.value.nil?
            if boolean_attribute.value
              info_rows << [attribute.name, "Sí"]
            else
              info_rows << [attribute.name, "No"]
            end
          else
            info_rows << [attribute.name, ""]
          end

        when "date"

          date_attribute = DateAttribute.where(attribute_id: attribute.id, client_id: client.id).first
          if !date_attribute.nil? && !date_attribute.value.nil?
            info_rows << [attribute.name, date_attribute.value.strftime("%d/%m/%Y")]
          else
            info_rows << [attribute.name, ""]
          end

        when "datetime"

          datetime_attribute = DateTimeAttribute.where(attribute_id: attribute.id, client_id: client.id).first
          if !datetime_attribute.nil? && !datetime_attribute.value.nil?
            datetime_val = datetime_attribute.value.strftime("%d/%m/%Y %R")
            info_rows << [attribute.name, datetime_val]
          else
            info_rows << [attribute.name, ""]
          end

        when "categoric"

          categoric_attribute = CategoricAttribute.where(attribute_id: attribute.id, client_id: client.id).first
          if !categoric_attribute.nil? && !categoric_attribute.attribute_category.nil?
            info_rows << [attribute.name, categoric_attribute.attribute_category.category]
          else
            info_rows << [attribute.name, ""]
          end

        end

			end

      info_rows << [""]
      info_rows << [""]

		end

		table(info_rows) do
			cells.borders = []
		end

		move_down 10

	end

end
