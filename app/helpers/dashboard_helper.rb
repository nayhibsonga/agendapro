module DashboardHelper
  STATUS_CLASS = ["blocked", "reserved", "confirmed", "completed", "payed", "cancelled", "noshow"]

  def label_class(booking)
    "label-#{STATUS_CLASS[booking.status_id]}"
  end
end
