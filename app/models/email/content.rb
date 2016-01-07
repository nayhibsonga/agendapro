class Email::Content < ActiveRecord::Base
  belongs_to :template, class_name: 'Email::Template'
  before_create :empty_json

  def empty_json
    if json.blank?
      json = {}
    end
  end
end
