class Email::ContentController < ApplicationController
  layout "admin"

  def new_content
    @content = Email::Content.find(params[:id])
    @from = @content.from
    @tmpl = @content.template
    render 'clients/email/full/mail_editor'
  end

  def editor
    @from_collection = current_user.company.company_from_email.where(confirmed: true).pluck(:email)

    (new_content if params[:id].present?) and return

    @from = current_user.email
    recipients = params[:recipients]
    @tmpl = Email::Template.find(params[:tmpl])
    @content = Email::Content.create(template: @tmpl, company: current_user.company, from: @from, to: recipients)

    render 'clients/email/full/mail_editor'
  end

  def update
    content = Email::Content.where(id: content_params[:id]).first
    updated = content.update(content_params.except(:id)) if content
    render json: {
      status: (updated ? :ok : :interal_server_error),
      url: url_for(:send_mail).to_s
    }
  end

  def upload
    if params[:file].present?
      begin
        uploader = EmailContentUploader.new
        uploader.store(params[:id], params[:file].tempfile)

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

  private

    def content_params
      params.require(:content).permit!
    end

    def upload_params
      params.permit(:id, :file)
    end

end
