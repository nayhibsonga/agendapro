class Email::Content < ActiveRecord::Base
  belongs_to :template, class_name: 'Email::Template'
  before_create :empty_json

  def empty_json
    if data.blank?
      data = {}
    end
  end

  def self.generate(id=nil, params)
    if id
      content = where(id: id).try(:first)
      if content
        content.update_attributes(params) ? content.id : nil
      end
    else
      content = Email::Content.create(params)

      content.present? ? content.id : nil
    end
  end
end
