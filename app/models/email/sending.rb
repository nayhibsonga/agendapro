class Email::Sending < ActiveRecord::Base
  belongs_to :sendable, polymorphic: true
  after_create :deliver, if: proc { |s| s.status == 'pending' && s.send_date.blank? }
  scope :sent, -> { where(status: 'delivered') }

  def deliver
    ClientEmailWorker.perform(self)
  end

end
