class ChartFieldFloat < ActiveRecord::Base
  belongs_to :chart_field
  belongs_to :chart
end
