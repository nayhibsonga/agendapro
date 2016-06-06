class ChartField < ActiveRecord::Base
  belongs_to :company
  belongs_to :chart_group
end
