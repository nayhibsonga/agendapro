class CreatePayUNotifications < ActiveRecord::Migration
  def change
    create_table :pay_u_notifications do |t|
      t.string :merchant_id
      t.string :state_pol
      t.string :risk
      t.string :response_code_pol
      t.string :reference_sale
      t.string :reference_pol
      t.string :sign
      t.string :extra1
      t.string :extra2
      t.string :payment_method
      t.string :payment_method_type
      t.string :installments_number
      t.string :value
      t.string :tax
      t.string :additional_value
      t.string :transaction_date
      t.string :currency
      t.string :email_buyer
      t.string :cus
      t.string :pse_bank
      t.string :test
      t.string :description
      t.string :billing_address
      t.string :shipping_address
      t.string :phone
      t.string :office_phone
      t.string :account_number_ach
      t.string :account_type_ach
      t.string :administrative_fee
      t.string :administrative_fee_base
      t.string :administrative_fee_tax
      t.string :airline_code
      t.string :attempts
      t.string :authorization_code
      t.string :bank_id
      t.string :billing_city
      t.string :billing_country
      t.string :commision_pol
      t.string :commision_pol_currency
      t.string :customer_number
      t.string :date
      t.string :error_code_bank
      t.string :error_message_bank
      t.string :exchange_rate
      t.string :ip
      t.string :nickname_buyer
      t.string :nickname_seller
      t.string :payment_method_id
      t.string :payment_request_state
      t.string :pseReference1
      t.string :pseReference2
      t.string :pseReference3
      t.string :response_message_pol
      t.string :shipping_city
      t.string :shipping_country
      t.string :transaction_bank_id
      t.string :transaction_id

      t.timestamps
    end
  end
end
