class ChartFieldBoolean < ActiveRecord::Base
  belongs_to :chart_field
  belongs_to :client
end
