class ChartGroup < ActiveRecord::Base
  belongs_to :company
  has_many :chart_fields
end
