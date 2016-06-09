class Chart < ActiveRecord::Base
  belongs_to :company
  belongs_to :client
  belongs_to :booking
  belongs_to :user

  has_many :chart_categories, dependent: :destroy
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
        chart_category = ChartCategory.create(chart_field_id: chart_field.id, category: "Otra")
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

end
