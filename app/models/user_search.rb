class UserSearch < ActiveRecord::Base
  belongs_to :user

  validate :user_id, :search_text, presence: true
end
