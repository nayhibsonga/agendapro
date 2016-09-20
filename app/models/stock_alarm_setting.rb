class StockAlarmSetting < ActiveRecord::Base
	belongs_to :location
	has_many :stock_setting_emails, dependent: :destroy
end
