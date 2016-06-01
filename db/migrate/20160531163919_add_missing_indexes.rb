class AddMissingIndexes < ActiveRecord::Migration
  def change
  	#Booking
  	remove_index :bookings, :payment_id
  	add_index :bookings, :payment_id, where: "payment_id is not null"
  	#add_index :bookings, :receipt_id, where: "receipt_id is not null"
  	#AttributeCategories
  	add_index :attribute_categories, :attribute_id
  	#AttributeGroups
  	add_index :attribute_groups, :company_id
  	#Attributes
  	add_index :attributes, :company_id
  	add_index :attributes, :attribute_group_id
  	#BillingLog
  	add_index :billing_logs, :created_at, order: { created_at: "DESC NULLS LAST" }
  	#BillingRecord
  	add_index :billing_records, :company_id
  	add_index :billing_records, :transaction_type_id
  	add_index :billing_records, :date, order: { date: "DESC NULLS LAST" }
  	#BillingWireTransfer
  	add_index :billing_wire_transfers, :company_id
  	add_index :billing_wire_transfers, :payment_date, order: { payment_date: "DESC NULLS LAST" }
  	#BookingEmailLog
  	add_index :booking_email_logs, :timestamp, order: { timestamp: "DESC NULLS LAST" }
  	#BookingHistory
  	add_index :booking_histories, :created_at, order: { created_at: "DESC NULLS LAST" }
  	#BooleanAttribute
  	add_index :boolean_attributes, :attribute_id
  	add_index :boolean_attributes, :client_id
  	#BooleanCustomFilter
  	add_index :boolean_custom_filters, :custom_filter_id
  	add_index :boolean_custom_filters, :attribute_id
  	#Cashier
  	add_index :cashiers, :company_id
  	#CategoricAttribute
  	add_index :categoric_attributes, :client_id
  	add_index :categoric_attributes, :attribute_id
  	add_index :categoric_attributes, :attribute_category_id
  	#CategoricCustomFilter
  	add_index :categoric_custom_filters, :custom_filter_id
  	add_index :categoric_custom_filters, :attribute_id
  	#ClientComment
  	add_index :client_comments, :created_at, order: { created_at: "DESC NULLS LAST" }
  	#ClientEmailLog
  	add_index :client_email_logs, :timestamp, order: { timestamp: "DESC NULLS LAST" }
  	#ClientFile
  	add_index :client_files, :client_id
  	#Company
  	add_index :companies, :sales_user_id
  	#CompanyCronLog
  	add_index :company_cron_logs, :company_id
  	#CompanyFile
  	add_index :company_files, :company_id
  	#CompanyPlanSetting
  	add_index :company_plan_settings, :company_id
  	#CustomFilter
  	add_index :custom_filters, :company_id
  	#DateAttribute
  	add_index :date_attributes, :attribute_id
  	add_index :date_attributes, :client_id
  	#DateCustomFilter
  	add_index :date_custom_filters, :custom_filter_id
  	add_index :date_custom_filters, :attribute_id
  	#DateTimeAttribute
  	add_index :date_time_attributes, :attribute_id
  	add_index :date_time_attributes, :client_id
  	#DowngradeLog
  	add_index :downgrade_logs, :company_id
  	add_index :downgrade_logs, :plan_id
  	#FileAttribute
  	add_index :file_attributes, :attribute_id
  	add_index :file_attributes, :client_id
  	#FloatAttribute
  	add_index :float_attributes, :attribute_id
  	add_index :float_attributes, :client_id
  	#IntegerAttribute
  	add_index :integer_attributes, :attribute_id
  	add_index :integer_attributes, :client_id
  	#InternalSale
  	add_index :internal_sales, :location_id
  	add_index :internal_sales, :cashier_id
  	add_index :internal_sales, :service_provider_id
  	add_index :internal_sales, :product_id
  	add_index :internal_sales, :user_id
  	add_index :internal_sales, :date, order: { date: "DESC NULLS LAST" }
  	#MockBooking
  	add_index :mock_bookings, :client_id, where: "client_id is not null"
  	add_index :mock_bookings, :service_id, where: "service_id is not null"
  	add_index :mock_bookings, :service_provider_id, where: "service_provider_id is not null"
  	add_index :mock_bookings, :payment_id
  	add_index :mock_bookings, :receipt_id
  	#NumericCustomFilter
  	add_index :numeric_custom_filters, :custom_filter_id
  	add_index :numeric_custom_filters, :attribute_id
  	#OnlineCancelationPolicy
  	add_index :online_cancelation_policies, :company_setting_id
  	#PayedBooking
  	add_index :payed_bookings, :punto_pagos_confirmation_id
  	add_index :payed_bookings, :payment_account_id
  	#PaymentAccount
  	add_index :payment_accounts, :company_id
  	#PaymentProduct
  	add_index :payment_products, :seller_id, where: "seller_id is not null"
  	add_index :payment_products, :receipt_id
  	#PaymentTransaction
  	add_index :payment_transactions, :payment_id
  	add_index :payment_transactions, :payment_method_id
  	add_index :payment_transactions, :company_payment_method_id
  	add_index :payment_transactions, :payment_method_type_id
  	#Payment
  	add_index :payments, :cashier_id, where: "cashier_id is not null"
  	add_index :payments, :payment_date, order: { payment_date: "DESC NULLS LAST" }
  	add_index :payments, :created_at, order: { created_at: "DESC NULLS LAST" }
  	#PettyCash
  	add_index :petty_cashes, :location_id
  	#PettyTransaction
  	add_index :petty_transactions, :petty_cash_id
  	add_index :petty_transactions, :date, order: { date: "DESC NULLS LAST" }
  	#ProductBrand
  	add_index :product_brands, :company_id
  	#ProductDisplay
  	add_index :product_displays, :company_id
  	#Product
  	add_index :products, :product_brand_id
  	add_index :products, :product_display_id
  	#ProviderBreak
  	add_index :provider_breaks, :break_group_id
  	add_index :provider_breaks, :break_repeat_id
  	#ReceiptProduct
  	add_index :receipt_products, :receipt_id
  	add_index :receipt_products, :product_id
  	#Receipt
  	add_index :receipts, :receipt_type_id
  	add_index :receipts, :payment_id
  	#SalesCashIncome
  	add_index :sales_cash_incomes, :sales_cash_id
  	add_index :sales_cash_incomes, :user_id
  	#SalesCashLog
  	add_index :sales_cash_logs, :sales_cash_id
  	#SalesCashTransaction
  	add_index :sales_cash_transactions, :sales_cash_id
  	add_index :sales_cash_transactions, :user_id
  	#SalesCash
  	add_index :sales_cashes, :location_id
  	#ServiceCommission
  	add_index :service_commissions, :service_provider_id
  	add_index :service_commissions, :service_id
  	#SessionBooking
  	add_index :session_bookings, :service_id
  	add_index :session_bookings, :user_id
  	add_index :session_bookings, :client_id
  	#StockAlarmSetting
  	add_index :stock_alarm_settings, :location_id
  	#StockEmail
  	add_index :stock_emails, :location_product_id
  	#StockSettingEmail
  	add_index :stock_setting_emails, :stock_alarm_setting_id
  	#TextAttribute
  	add_index :text_attributes, :attribute_id
  	add_index :text_attributes, :client_id
  	#TextCustomFilter
  	add_index :text_custom_filters, :custom_filter_id
  	add_index :text_custom_filters, :attribute_id
  	#TextareaAttribute
  	add_index :textarea_attributes, :attribute_id
  	add_index :textarea_attributes, :client_id

  end
end
