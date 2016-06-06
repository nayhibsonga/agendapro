class ChartFieldCategoric < ActiveRecord::Base
  belongs_to :chart_field
  belongs_to :client
  belongs_to :chart_category
end
