# config valid only for Capistrano 3.1

lock '3.1.0'

set :application, 'agendapro-railsweb'

set :repo_url, 'https://agendapro:G*g8~1GEQ]@bitbucket.org/agendapro/agendapro-railsweb'

set :deploy_to, '/home/agendapro/web_app'

set :branch, 'development-test'

set :linked_files, %w{config/database.yml config/local_env.yml}

#Cambiar esto para que se copien los bins y otros.

set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

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
