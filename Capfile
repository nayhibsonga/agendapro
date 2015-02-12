# Load DSL and Setup Up Stages

require 'capistrano/setup'

# Includes default deployment tasks

require 'capistrano/deploy'

require 'capistrano/bundler'

require 'capistrano/rails'

require 'capistrano/rvm'

require 'capistrano/delayed-job'

set :rvm_type, :user

set :rvm_ruby_version, '2.0.0p598'

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.

Dir.glob('lib/capistrano/tasks/*.cap').each { |r| import r }