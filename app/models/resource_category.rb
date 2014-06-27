class ResourceCategory < ActiveRecord::Base
  has_many :resources
  belongs_to :company
end
