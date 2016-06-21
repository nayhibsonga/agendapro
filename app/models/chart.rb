class Chart < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :booking
  belongs_to :user
  belongs_to :last_modifier, class_name: "User"

  has_many :chart_field_booleans, dependent: :destroy
  has_many :chart_field_categorics, dependent: :destroy
  has_many :chart_field_dates, dependent: :destroy
  has_many :chart_field_datetimes, dependent: :destroy
  has_many :chart_field_files, dependent: :destroy
  has_many :chart_field_floats, dependent: :destroy
  has_many :chart_field_integers, dependent: :destroy
  has_many :chart_field_texts, dependent: :destroy
  has_many :chart_field_textareas, dependent: :destroy

  def create_chart_fields

    self.company.chart_fields.each do |chart_field|

      if chart_field.datatype == "categoric"
        chart_category = ChartCategory.create(chart_field_id: chart_field.id, name: "Otra")
      end

      case chart_field.datatype
      when "float"

        if ChartFieldFloat.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldFloat.create(chart_field_id: chart_field.id, chart_id: self.id)
        end

      when "integer"

        if ChartFieldInteger.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldInteger.create(chart_field_id: chart_field.id, chart_id: self.id)
        end

      when "text"

        if ChartFieldText.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldText.create(chart_field_id: chart_field.id, chart_id: self.id, value: "")
        end

      when "textarea"

        if ChartFieldTextarea.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldTextarea.create(chart_field_id: chart_field.id, chart_id: self.id, value: "")
        end

      when "boolean"

        if ChartFieldBoolean.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldBoolean.create(chart_field_id: chart_field.id, chart_id: self.id)
        end

      when "date"

        if ChartFieldDate.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldDate.create(chart_field_id: chart_field.id, chart_id: self.id)
        end

      when "datetime"

        if ChartFieldDatetime.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldDatetime.create(chart_field_id: chart_field.id, chart_id: self.id)
        end

      when "file"
        if ChartFieldFile.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldFile.create(chart_field_id: chart_field.id, chart_id: self.id)
        end
      when "categoric"
        chart_category = ChartCategory.create(chart_field_id: chart_field.id, category: "Otra")
        if ChartFieldCategoric.where(chart_field_id: chart_field.id, chart_id: self.id).count == 0
          ChartFieldCategoric.create(chart_field_id: chart_field.id, chart_id: self.id, chart_category_id: chart_category.id)
        end
      end

    end

  end

  def get_chart_fields

    chart_fields = {}

    self.company.chart_fields.each do |chart_field|

      case chart_field.datatype

      when "float"

        field = ChartFieldFloat.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if !field.nil? && !field.value.nil?
          chart_fields[chart_field.slug + "_chart_field"] = field.value
        else
          chart_fields[chart_field.slug + "_chart_field"] = nil
        end

      when "integer"

        field = ChartFieldInteger.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if !field.nil? && !field.value.nil?
          chart_fields[chart_field.slug + "_chart_field"] = field.value
        else
          chart_fields[chart_field.slug + "_chart_field"] = nil
        end

      when "text"

        field = ChartFieldText.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if !field.nil? && !field.value.nil?
          chart_fields[chart_field.slug + "_chart_field"] = field.value
        else
          chart_fields[chart_field.slug + "_chart_field"] = ""
        end

      when "textarea"

        field = ChartFieldTextarea.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if !field.nil? && !field.value.nil?
          chart_fields[chart_field.slug + "_chart_field"] = field.value
        else
          chart_fields[chart_field.slug + "_chart_field"] = ""
        end

      when "boolean"

        field = ChartFieldBoolean.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if !field.nil? && !field.value.nil?
          if field.value
            chart_fields[chart_field.slug + "_chart_field"] = true
          else
            chart_fields[chart_field.slug + "_chart_field"] = false
          end
        else
          chart_fields[chart_field.slug + "_chart_field"] = false
        end

      when "date"

        field = ChartFieldDate.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if !field.nil? && !field.value.nil?
          chart_fields[chart_field.slug + "_chart_field"] = field.value
        else
          chart_fields[chart_field.slug + "_chart_field"] = nil
        end

      when "datetime"

        field = ChartFieldDatetime.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if !field.nil? && !field.value.nil?
          chart_fields[chart_field.slug + "_chart_field"] = field.value.strftime('%d/%m/%Y')
          chart_fields[chart_field.slug + "_chart_field_hour"] = field.value.strftime('%H')
          chart_fields[chart_field.slug + "_chart_field_minute"] = field.value.strftime('%M')
        else
          chart_fields[chart_field.slug + "_chart_field"] = ""
          chart_fields[chart_field.slug + "_chart_field_hour"] = nil
          chart_fields[chart_field.slug + "_chart_field_minute"] = nil
        end

      when "categoric"

        field = ChartFieldCategoric.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if !field.nil?
          chart_fields[chart_field.slug + "_chart_field"] = field.chart_category_id
        else
          chart_fields[chart_field.slug + "_chart_field"] = nil
        end

      end

    end

    return chart_fields

  end

  def save_chart_fields(params)

    if params.blank?
      return
    end

    self.company.chart_fields.each do |chart_field|

      str_sm = chart_field.slug + "_chart_field"

      if !params.keys.include?(str_sm)
        next
      end

      param_value = params[str_sm]

      case chart_field.datatype
      when "float"

        chart_field_float = ChartFieldFloat.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if chart_field_float.nil?
          chart_field_float = ChartFieldFloat.create(chart_field_id: chart_field.id, chart_id: self.id, value: param_value)
        else
          chart_field_float.value = param_value
          chart_field_float.save
        end

      when "integer"

        chart_field_integer = ChartFieldInteger.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if chart_field_integer.nil?
          ChartFieldInteger.create(chart_field_id: chart_field.id, chart_id: self.id, value: param_value)
        else
          chart_field_integer.value = param_value
          chart_field_integer.save
        end

      when "text"

        chart_field_text = ChartFieldText.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if chart_field_text.nil?
          ChartFieldText.create(chart_field_id: chart_field.id, chart_id: self.id, value: param_value)
        else
          chart_field_text.value = param_value
          chart_field_text.save
        end

      when "textarea"

        chart_field_textarea = ChartFieldTextarea.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if chart_field_textarea.nil?
          ChartFieldTextarea.create(chart_field_id: chart_field.id, chart_id: self.id, value: param_value)
        else
          chart_field_textarea.value = param_value
          chart_field_textarea.save
        end

      when "boolean"
        logger.debug "Boolean: " + param_value
        if param_value == 1 || param_value == "1" || param_value == true
          param_boolean = true
        else
          param_boolean = false
        end

        chart_field_boolean = ChartFieldBoolean.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if chart_field_boolean.nil?
          ChartFieldBoolean.create(chart_field_id: chart_field.id, chart_id: self.id, value: param_boolean)
        else
          chart_field_boolean.value = param_boolean
          chart_field_boolean.save
        end

      when "date"

        if !param_value.blank?
          param_value = param_value.gsub('/', '-')
        end

        chart_field_date = ChartFieldDate.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if chart_field_date.nil?
          ChartFieldDate.create(chart_field_id: chart_field.id, chart_id: self.id, value: param_value)
        else
          chart_field_date.value = param_value
          chart_field_date.save
        end

      when "datetime"

        if !param_value.blank?
          param_value = param_value.gsub('/', '-')
          date_hour = params[chart_field.slug + "_chart_field_hour"]
          date_minute = params[chart_field.slug + "_chart_field_minute"]
        end

        complete_datetime = nil
        if !param_value.blank?
          complete_datetime = param_value + " " + date_hour + ":" + date_minute + ":00"
        end

        chart_field_datetime = ChartFieldDatetime.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if chart_field_datetime.nil?
          ChartFieldDatetime.create(chart_field_id: chart_field.id, chart_id: self.id, value: complete_datetime)
        else
          chart_field_datetime.value = complete_datetime
          chart_field_datetime.save
        end

      when "file"

        chart_field_file = ChartFieldFile.where(chart_field_id: chart_field.id, chart_id: self.id).first

        if !param_value.blank?

          file_name = chart_field.name
          folder_name = chart_field.slug
          content_type = param_value.content_type

          file_extension = param_value.original_filename[param_value.original_filename.rindex(".") + 1, param_value.original_filename.length]

          file_description = chart_field.description

          full_name = 'companies/' +  self.company_id.to_s + '/clients/' + self.id.to_s + '/' + folder_name + '/' + param_value.original_filename

          s3_bucket = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

          obj = s3_bucket.object(full_name)

          obj.upload_file(param_value.path(), {acl: 'public-read', content_type: content_type})

          client_file = ClientFile.create(client_id: self.client_id, name: file_name, full_path: full_name, public_url: obj.public_url, size: obj.size, description: file_description)

          if chart_field_file.nil?
            ChartFieldFile.create(chart_field_id: chart_field.id, chart_id: self.id, client_file_id: client_file.id)
          else
            if !chart_field_file.client_file.nil?
              chart_field_file.client_file.destroy
            end
            chart_field_file.client_file_id = client_file.id
            chart_field_file.save
          end

        end


      when "categoric"

        chart_field_categoric = ChartFieldCategoric.where(chart_field_id: chart_field.id, chart_id: self.id).first
        if chart_field_categoric.nil?
          ChartFieldCategoric.create(chart_field_id: chart_field.id, chart_id: self.id, chart_category_id: param_value)
        else
          chart_field_categoric.chart_category_id = param_value
          chart_field_categoric.save
        end

      end

    end

  end

end
