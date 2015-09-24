class HoraChic::AngularController < ApplicationController
  layout false

  # Actions to redirect to specific views in Frontend.
  # This are going to be replaced with direct
  # routes in Angular in a separated app

  # Cross App Views
  def index; end
  def header; end
  def footer; end

  # Specific views
  def landing; end

end