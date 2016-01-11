class Email::Content < ActiveRecord::Base
  belongs_to :template, class_name: 'Email::Template'
  before_create :empty_json

  def self.generate(id, params)
    content = where(id: id).try(:first)
    if content
      content.update(params) ? content.id : nil
    end
  end

  private
    def empty_json
      if data.blank?
        data = {}
      end
    end
end
