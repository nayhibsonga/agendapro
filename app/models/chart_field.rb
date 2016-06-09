class ChartField < ActiveRecord::Base
  belongs_to :company
  belongs_to :chart_group

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

  def rearrange

    #Check order isn't past current gratest order
    greatest_order = ::ChartField.where(company_id: self.company_id, chart_group_id: self.chart_group_id).where.not(id: self.id).maximum(:order)
    if greatest_order.nil?
      greatest_order = 0
    end
    if self.order.nil? || self.order < 1 || self.order > greatest_order + 1
      self.update_column(:order, greatest_order + 1)
    end

    #Check if order exists and rearrange
    if ::ChartField.where(company_id: self.company_id, chart_group_id: self.chart_group_id, order: self.order).where.not(id: self.id).count > 0
      later_chart_fields = ::ChartField.where(company_id: self.company_id, chart_group_id: self.chart_group_id).where('chart_fields.order >= ?', self.order).where.not(id: self.id)
      later_chart_fields.each do |c_field|
        c_field.update_column(:order, c_field.order + 1)
      end
    end
  end

  def get_greatest_order
    greatest_order = ::ChartFields.where(company_id: self.company_id, chart_group_id: self.chart_group_id).maximum(:order)
    if greatest_order.nil?
      greatest_order = 0
    end
    return greatest_order
  end

  def generate_slug
    new_slug = self.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').squish.downcase.tr(" ","_").to_s
    self.update_column(:slug, new_slug)
  end

end
