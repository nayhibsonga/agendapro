# encoding: utf-8

class LogoUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    'uploads/logos'
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
    ActionController::Base.helpers.asset_path("logo_vacio.png")
    # "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # Process files as they are uploaded:
  process :convert => 'png'
  process :resize_to_limit => [200, 200]

  # Create different versions of your uploaded files:
  version :email do
    process :convert => 'png'
    process :resize_to_limit => [200, 120]
  end

  version :thumb do
    process :convert => 'png'
    process :resize_and_pad => [80, 80]
  end

  version :page do
    process :convert => 'png'
    process :resize_and_pad => [200, 200]
  end

  # def scale(width, height)
  #   :resize_to_limit => [width, height]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{model.web_address}.png" if original_filename
  end

end
