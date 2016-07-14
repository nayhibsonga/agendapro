class PrintChartPdf < Prawn::Document
	def initialize(chart_id)

		font_families.update(
			"Roboto" => {
				normal: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Light.ttf')}", font: 'Roboto Condensed Light'},
				bold: { file: "#{Rails.root.join('public/fonts/RobotoCondensed-Bold.ttf')}", font: 'Roboto Condensed Bold'}
			}
		)
		super()
		font 'Roboto'

    @chart = Chart.find(chart_id)
		@client = @chart.client
		@company = @client.company
		header(@chart, @client, @company)		

	end

	def header(chart, client, company)

		y_position = cursor
		bounding_box([220, y_position], width: 260, height: 30) do
			text "<b>Ficha de " + client.full_name + "</b>",
				:inline_format => true
		end

		info_rows = []

		info_rows << ["Fecha: ", chart.date.strftime("%d/%m/%Y %R")]
    info_rows << ["Autor: ", "#{chart.user.full_name}"]
    if chart.booking.nil?
      info_rows << ["Reserva: ", "Sin reserva"]
    else
      info_rows << ["Reserva: ", "#{chart.booking.service.name} con #{chart.booking.service_provider.public_name}, el " + chart.booking.start.strftime("%d/%m/%Y %R")]
    end

    timezone_offset = chart.company.country.timezone_offset
    if chart.created_at != chart.updated_at
      if chart.last_modifier.nil?
        info_rows << ["Última modificación: ", (@chart.updated_at + timezone_offset.hours).strftime("%d/%m/%Y %R")]
      else
        info_rows << ["Última modificación: ", (@chart.updated_at + timezone_offset.hours).strftime("%d/%m/%Y %R") + " por #{@chart.last_modifier.full_name}"]
      end
    else
        info_rows << ["Última modificación: ", "Sin modificaciones"]
    end

		

		move_down 20
    info_rows << [""]
    info_rows << [""]

		company.chart_groups.order(:order).each do |chart_group|

			info_rows << [chart_group.name + ":"]

			move_down 20
      info_rows << [""]
      info_rows << [""]

			chart_group.chart_fields.order(:order).each do |chart_field|

				field_value = ""
        if chart_field.datatype == "integer"
          field = chart.chart_field_integers.where(chart_field_id: chart_field.id).first
          if !field.nil?
            field_value = "#{field.value}"
          end
        elsif chart_field.datatype == "float"
          field = chart.chart_field_floats.where(chart_field_id: chart_field.id).first
          if !field.nil?
            field_value = "#{field.value}"
          end
        elsif chart_field.datatype == "text"
          field = chart.chart_field_texts.where(chart_field_id: chart_field.id).first
          if !field.nil?
            field_value = "#{field.value}"
          end
        elsif chart_field.datatype == "textarea"
          field = chart.chart_field_textareas.where(chart_field_id: chart_field.id).first
          if !field.nil?
            field_value = "#{field.value}"
          end
        elsif chart_field.datatype == "boolean" 
          field = chart.chart_field_booleans.where(chart_field_id: chart_field.id).first
          if !field.nil?
            if !field.value.nil?
              if field.value
                field_value = "Sí"
              else
                field_value = "No"
              end
            end
          end
        elsif chart_field.datatype == "date"
          field = chart.chart_field_dates.where(chart_field_id: chart_field.id).first
          if !field.nil? && !field.value.nil?
            field_value = field.value.strftime("%d/%m/%Y")
          end
        elsif chart_field.datatype == "datetime"
          field = chart.chart_field_datetimes.where(chart_field_id: chart_field.id).first
          if !field.nil? && !field.value.nil?
            field_value = field.value.strftime("%d/%m/%Y %R")
          end
        elsif chart_field.datatype == "categoric"
          field = chart.chart_field_categorics.where(chart_field_id: chart_field.id).first
          if !field.nil? && !field.chart_category.nil?
            field_value = field.chart_category.name
          end
        elsif chart_field.datatype == "file"
          field = chart.chart_field_files.where(chart_field_id: chart_field.id).first
          if !field.nil? && !field.client_file.nil?
            field_value = field.client_file.public_url
          end
        end

        info_rows << [chart_field.name + ":", field_value]

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
