# Remove Rack::Lock so WEBrick can be fully multi-threaded.
require 'rails/commands/server'

if Rails.env.pagos?
	class Rails::Server
	  def middleware
	    middlewares = []
	    middlewares << [Rails::Rack::Debugger] if options[:debugger]
	    middlewares << [::Rack::ContentLength]

	    Hash.new middlewares
	  end
	end
end