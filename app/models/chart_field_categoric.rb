class ChartFieldCategoric < ActiveRecord::Base
  belongs_to :chart_field
  belongs_to :chart
  belongs_to :chart_category
end
