class Email::Content < ActiveRecord::Base
  belongs_to :template, class_name: 'Email::Template'
  belongs_to :company
  has_many :sendings, as: :sendable

  attr_accessor :send_email

  before_create :empty_json
  after_update :generate_sending, if: :send_email

  validates_presence_of :template, :to, :company

  scope :of_company, -> (c) { where(company: c) unless c.nil? }
  scope :actives, -> { where(active: true) }
  scope :inactives, -> { where(active: false) }

  def generate_sending
    Email::Sending.create(
      sendable_id: self.id,
      sendable_type: self.class.name
      )
  end

  def sent?
    self.sendings.sent.size > 0
  end

  def has_sendings?
    self.sendings.size > 0
  end

  def destroy
    success = false
    if self.has_sendings?
      success = self.update(active: false, deactivation_date: Time.now)
      success = self.sendings.pendings.update_all(status: 'canceled')
    else
      success = self.delete
    end
    success
  end

  private

    def empty_json
      self.data = {} if self.data.blank?
    end
end
