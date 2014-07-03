class ResourceLocation < ActiveRecord::Base
  belongs_to :resource
  belongs_to :location
end
