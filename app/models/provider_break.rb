class ProviderBreak < ActiveRecord::Base
  belongs_to :service_provider

  validates :start, :end, :presence => true

  validate :time_empty_or_negative

  validation_scope(:warnings) do |s|
    s.validate after_commit :provider_in_booking
  end

	def time_empty_or_negative
		if self.start >= self.end
			errors.add(:base, "Existen horarios vacíos o negativos.")
		end
  end


  def provider_in_booking
    if !self.break_group_id? && !self.break_repeat_id?
      self.service_provider.bookings.where.not(status_id: Status.find_by_name("Cancelado").id).where("bookings.start < ?", self.end).where("bookings.end > ?", self.start).where('is_session = false or (is_session = true and is_session_booked = true)').each do |booking|
        if (booking.start - self.end) * (self.start - booking.end) > 0
          warnings.add(:base, "El prestador seleccionado tiene una reserva en el horario bloqueado")
          return
        end
      end
    end
  end
end
