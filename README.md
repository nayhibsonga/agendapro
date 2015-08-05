# AgendaPro #
![AgendaPro](http://agendapro.cl/assets/logos/logo2.png)

## Ruby version ##
### Install RVM ###
```
user@agendapro$: sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
user@agendapro$: curl -L https://get.rvm.io | bash -s stable --auto-dotfiles
user@agendapro$: source ~/.rvm/scripts/rvm
user@agendapro$: echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
```
### Install Ruby ###
```
user@agendapro$: rvm install 2.0.0
user@agendapro$: rvm use 2.0.0 --default
user@agendapro$: ruby -v
user@agendapro$: echo "gem: --no-ri --no-rdoc" > ~/.gemrc
```

## System dependencies ##
1. Install ImageMagick: `sudo apt-get install ImageMagick libmagickwand-dev`
1. Test ImageMagick: `convert`
1. Usin ImageMagick: `convert zoolander.jpg -resize 200x200 -background transparent -gravity center -extent 200x200 zoolander.jpg`

## Configuration ##
### Log rotation ###
* Create file /etc/logrotate.d/web-app with superuser permissions.
* Paste the following formula:
```
# /etc/logrotate.d/web-app
# Rotate Rails application logs based on file size
# Rotate log if file greater than 20 MB
/home/agendapro/web_app/log/*.log {
    daily
    missingok
    rotate 90
    dateext
    dateformat .%Y-%m-%d
    compress
    delaycompress
    notifempty
    copytruncate
}
```
* run twice in console to check log creation and compression `sudo /usr/sbin/logrotate -f /etc/logrotate.conf`

## Database ##
### Database Instalation ###
```
sudo apt-get install postgresql postgresql-contrib
sudo apt-get install pgadmin3
```
### Database creation ###
```
CREATE USER tom WITH CREATEDB PASSWORD 'myPassword';
```
### Database initialization ###
```
bundle install
sudo nano /etc/postgresql/9.3/main/pg_hba.conf
  local   all         postgres                          md5
sudo /etc/init.d/postgresql restart
rake db:setup
```

## Agregar llaves ssh al servidor ##
* Generar llave en servidor local
```
me@localhost$: ssh-keygen -t rsa -C 'username@agendapro.cl'
```
* Obtener la parte publica de la llave
```
me@localhost$: ssh-add -L
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA ... cT4TVrx7z8pN4+JqSch username@agendapro.cl
```
* Agregar la llave
```
me@localhost$ ssh root@agendapro.cl
root@agendapro.cl$ su - agendapro
agendapro@agendapro.cl$ cd ~/.ssh
agendapro@agendapro.cl$ echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABA ... cT4TVrx7z8pN4+JqSch username@agendapro.cl" >> .ssh/authorized_keys
```

## Services (job queues, cache servers, search engines, etc.) ##
```
Update Cronjobs (Whenever Gem): whenever --update-crontab agendapro --set environment=production
```

## Publicar página de Facebook ##
```
https://www.facebook.com/dialog/pagetab?app_id=YOUR_APP_ID&next=YOUR_URL
```
