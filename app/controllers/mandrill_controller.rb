class MandrillController < ApplicationController
	require 'mandrill'
	require 'base64'
	layout 'login'
  
  def confirm_unsuscribe
  	@email  = Base64.decode64(params[:user])
  end

  def unsuscribe
  	mandrill = Mandrill::API.new 'HL4ERbuZZO6rrM2nlVjzZg'

  	# => Decodificando el email del usuario
  	email = Base64.decode64(params[:user])
  	comment = "Manual unsuscribe"

  	result = mandrill.rejects.add email, comment

  	redirect_to root_path

  rescue Mandrill::Error => e
  	puts "A mandrill error occurred: #{e.class} - #{e.message}"
  	raise
  end

  def resuscribe
  	mandrill = Mandrill::API.new 'HL4ERbuZZO6rrM2nlVjzZg'
  	email = Base64.encode64(user.email)
  	result = mandrill.rejects.delete email

  rescue Mandrill::Error => e
  	puts "A mandrill error occurred #{e.class} - #{e.message}"
  	raise
  end
end
