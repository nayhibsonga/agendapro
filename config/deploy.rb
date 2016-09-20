# config valid only for Capistrano 3.1

lock '3.1.0'

set :application, 'agendapro'

set :repo_url, 'git@bitbucket.org:agendapro/agendapro-railsweb.git'

#Cambiar esto para que se copien los bins y otros.

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads public/clients_files public/bookings_files public/payments_files public/products_files}

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

set :delayed_job_pid_dir, '/tmp'

set :keep_releases, 2

namespace :deploy do

   desc 'Restart application'

   task :restart do

     on roles(:app), in: :sequence, wait: 5 do

      execute :touch, release_path.join('tmp/restart.txt')

   end

 end

 after :publishing, 'deploy:restart'

 after :finishing, 'deploy:cleanup'

end
