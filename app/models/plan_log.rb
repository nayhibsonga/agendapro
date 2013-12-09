class PlanLog < ActiveRecord::Base
	belongs_to :company

	has_one :prev_plan_id, :class_name => "Plan"
	has_one :new_plan_id, :class_name => "Plan"
end
