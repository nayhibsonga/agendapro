set :stage, :production

server 'bambucalendar.cl', user: 'agendapro', roles: %w{web app db}

set :deploy_to, '/home/agendapro/development-np'

set :branch, 'master'

set :linked_files, %w{config/database.yml config/local_env.yml config/puntopagos.yml}

set :delayed_job_workers, 4


# before  'deploy:assets:precompile', 'deploy:migrate'
