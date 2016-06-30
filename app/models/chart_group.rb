class ChartGroup < ActiveRecord::Base
  belongs_to :company
  has_many :chart_fields

  after_save :rearrange
  before_destroy :transfer_chart_fields

  validate :name_uniqueness

  def transfer_attributes
    group_otros = ChartGroup.where(name: "Otros", company_id: self.company.id).first
    self.chart_fields.each do |chart_field|
      chart_field.chart_group_id = group_otros.id
      chart_field.order = group_otros.get_chart_fields_greatest_order + 1
      chart_field.save
    end
  end

  def name_uniqueness
    ChartGroup.where(name: self.name, company_id: self.company_id).each do |chart_group|
      if chart_group != self
        errors.add(:base, "No se pueden crear dos categorías con el mismo nombre.")
      end
    end
  end

 	def rearrange

		#Check order isn't past current gratest order
		greatest_order = ChartGroup.where(company_id: self.company_id).where.not(id: self.id).maximum(:order)
		
		if greatest_order.nil?
			greatest_order = 0
		end

		if self.order.nil? || self.order < 1 || self.order > greatest_order + 1
			self.update_column(:order, greatest_order + 1)
		end

		#Check if order exists and rearrange
		if ChartGroup.where(company_id: self.company_id, order: self.order).where.not(id: self.id).count > 0
			later_groups = ChartGroup.where(company_id: self.company_id).where('chart_groups.order >= ?', self.order).where.not(id: self.id)
			later_groups.each do |ch_group|
				ch_group.update_column(:order, ch_group.order + 1)
			end
		end
	end

	def get_greatest_order
		greatest_order = ChartGroup.where(company_id: self.company_id).maximum(:order)
		if greatest_order.nil?
			greatest_order = 0
		end
		return greatest_order
	end

	def get_chart_fields_greatest_order
		if self.chart_fields.count < 1
			return 0
		end
		greatest_order = self.chart_fields.maximum(:order)
		if greatest_order.nil?
			greatest_order = 0
		end
		return greatest_order
	end

end
