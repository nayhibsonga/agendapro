# encoding: utf-8

class EmailContentUploader < CarrierWave::Uploader::Base
  configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',                         # required
      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],      # required
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],  # required
      :region                 => ENV['AWS_REGION']#,             # optional, defaults to 'us-east-1'
      # :host                   => 's3.example.com',              # optional, defaults to nil
      # :endpoint               => 'https://s3.example.com:8080'  # optional, defaults to nil
    }
    config.fog_directory  = ENV['S3_BUCKET']                       # required
    config.fog_public     = true                                   # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=31536000'}  # optional, defaults to {}
  end

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  # storage :file
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "email_content/"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  process :convert => 'png'
  # process :resize_to_limit => [200, 200]

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    "#{SecureRandom.uuid}.png" if original_filename
  end

end
