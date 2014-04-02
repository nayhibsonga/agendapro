class Dictionary < ActiveRecord::Base
  belongs_to :tags

  validates :name, :presence => true
end
