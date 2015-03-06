class AddMonthlyMailsToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :monthly_mails, :integer, default: 5000, null: false

	  Plan.all.each do |plan|
	  	mails = plan.locations * 5000
	  	plan.monthly_mails = mails
	  	plan.save!
	  end
  end

end
