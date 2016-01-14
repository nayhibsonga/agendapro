class Email::Sending < ActiveRecord::Base
  belongs_to :sendable, polymorphic: true
  after_create :deliver, if: proc { |s| s.status == 'pending' && s.send_date.blank? }

  def deliver
    ClientMailer.send_campaign(self.sendable_id).deliver
  end

end
