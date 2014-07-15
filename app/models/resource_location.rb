class ResourceLocation < ActiveRecord::Base
  belongs_to :resource
  belongs_to :location

  validates :quantity, :numericality => { :greater_than => 0 }
end
