class AddBookingLeapsToCompanyAndProvider < ActiveRecord::Migration
  def change
    add_column :company_settings, :booking_leap, :integer, default: 15
    add_column :service_providers, :booking_leap, :integer, default: 15

    CompanySetting.all.each do |company_setting|
      company_setting.update(:booking_leap => company_setting.calendar_duration)
    end

    ServiceProvider.all.each do |service_provider|
      service_provider.update(:booking_leap => service_provider.block_length)
    end

  end
end
