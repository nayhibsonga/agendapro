class CreatePayUResponses < ActiveRecord::Migration
  def change
    create_table :pay_u_responses do |t|
      t.string :merchantId
      t.string :transactionState
      t.string :risk
      t.string :polResponseCode
      t.string :referenceCode
      t.string :reference_pol
      t.string :signature
      t.string :polPaymentMethod
      t.string :polPaymentMethodType
      t.string :installmentsNumber
      t.string :TX_VALUE
      t.string :TX_TAX
      t.string :buyerEmail
      t.string :processingDate
      t.string :currency
      t.string :cus
      t.string :pseBank
      t.string :lng
      t.string :description
      t.string :lapResponseCode
      t.string :lapPaymentMethod
      t.string :lapPaymentMethodType
      t.string :lapTransactionState
      t.string :message
      t.string :extra1
      t.string :extra2
      t.string :extra3
      t.string :authorizationCode
      t.string :merchant_address
      t.string :merchant_name
      t.string :merchant_url
      t.string :orderLanguage
      t.string :pseCycle
      t.string :pseReference1
      t.string :pseReference2
      t.string :pseReference3
      t.string :telephone
      t.string :transactionId
      t.string :trazabilityCode
      t.string :TX_ADMINISTRATIVE_FEE
      t.string :TX_TAX_
      t.string :ADMINISTRATIVE_FEE
      t.string :TX_TAX_ADMINISTRATIVE
      t.string :_FEE_RETURN_BASE
      t.string :action_code_description
      t.string :cc_holder
      t.string :cc_number
      t.string :processing_date_time
      t.string :request_number

      t.timestamps
    end
  end
end
