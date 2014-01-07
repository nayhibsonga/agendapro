class Dictionary < ActiveRecord::Base
  belongs_to :tags

  validates :name, :tag_id, :presence => true
end
