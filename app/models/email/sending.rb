class Email::Sending < ActiveRecord::Base
  belongs_to :sendable, polymorphic: true
  after_create :deliver, if: proc { |s| s.status == 'pending' && s.send_date.blank? }
  after_update :remove_job, if: proc { |s| s.status == 'canceled' }

  scope :sent, -> { where(status: 'delivered') }
  scope :pendings, -> { where(status: 'pending') }
  scope :canceled, -> { where(status: 'canceled') }
  scope :of_this_month, -> { where(sent_date: Date.today.beginning_of_month..Date.today.end_of_month) }

  def deliver
    class_eval(sendable.class::WORKER).perform(self)
  end

  def remove_job
    #TODO ON SIDEKIQ IMPLEMENTATION
  end

end
