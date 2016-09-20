class CreateOnlineCancelationPolicies < ActiveRecord::Migration
  def change
    create_table :online_cancelation_policies do |t|
      t.boolean :cancelable
      t.float :cancel_max_hours
      t.boolean :modifiable
      t.string :modification_unit
      t.float :modification_max

      t.timestamps
    end
  end
end
