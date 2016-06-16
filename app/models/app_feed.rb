class AppFeed < ActiveRecord::Base
  mount_uploader :image, AppFeedUploader

  belongs_to :company
end
