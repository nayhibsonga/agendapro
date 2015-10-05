class CreateProviderGroupAuxes < ActiveRecord::Migration
  def change
    create_table :provider_group_auxes do |t|
      t.references :provider_group, index: true
      t.references :service_provider, index: true

      t.timestamps
    end
  end
end
