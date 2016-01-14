class Email::Content < ActiveRecord::Base
  belongs_to :template, class_name: 'Email::Template'
  belongs_to :company
  has_many :sendings, as: :sendable

  attr_accessor :send_email

  before_create :empty_json
  after_update :generate_sending, if: :send_email

  scope :of_company, -> (c) { where(company: c) unless c.nil? }

  def self.generate(id, params)
    content = where(id: id).try(:first)
    content.update(params) if content
  end

  def generate_sending
    Email::Sending.build
  end

  def sent?
    self.sendings.sent > 0
  end

  private

    def empty_json
      self.data = {} if self.data.blank?
    end
end
