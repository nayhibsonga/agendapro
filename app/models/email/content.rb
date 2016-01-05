class Email::Content < ActiveRecord::Base
  belongs_to :template
end
