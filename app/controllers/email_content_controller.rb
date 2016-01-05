class EmailContentController < ApplicationController

  def upload
    if !params[:file].blank?
      begin
        uploader = EmailContentUploader.new
        uploader.store!(params[:file].tempfile)

        render json: {
          filename: uploader.file.filename,
          path: uploader.path,
          url: uploader.url
        }.to_json
      rescue
        render json: { error: "Error processing file"}, status: :unprocessable_entity
      end
    else
      render json: { error: "No file attached"}, status: :unprocessable_entity
    end
  end
end
