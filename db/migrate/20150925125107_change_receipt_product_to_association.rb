class ChangeReceiptProductToAssociation < ActiveRecord::Migration
	
	def change
		def up
			drop_table :receipt_products
			add_column :payment_products, :receipt_id, :integer
		end

		def down
			create_table :receipt_products do |t|
				t.integer :receipt_id
				t.integer :product_id
				t.float :price
				t.float :discount
				t.integer :quantity

				t.timestamps
			end
		end
	end

end
