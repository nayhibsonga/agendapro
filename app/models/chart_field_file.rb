class ChartFieldFile < ActiveRecord::Base
  belongs_to :chart_field
  belongs_to :client
  belongs_to :client_file
end
