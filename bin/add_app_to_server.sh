mapc_users=(mzagaja ericyoungberg iangmhill)
app_name=$1
ruby_version=$2

## User Setup for Deploy Users
sudo adduser -q --disabled-password --gecos "" $app_name
sudo mkdir -p /var/www/$app_name/shared/config

# Edit the deploy configuration files
# nano /var/www/$app_name/shared/config/database.yml &&
# nano /var/www/$app_name/shared/config/secrets.yml

sudo chown -R $app_name:$app_name /var/www/$app_name

# chmod 600 /var/www/$app_name/shared/config/database.yml
# chmod 600 /var/www/$app_name/shared/config/secrets.yml

#setup a postgres db for the user if on staging
sudo -u postgres createuser $app_name
createdb $app_name

#Add passwordless sudo for deploy user
# sudo bash -c 'echo "$1 ALL=(ALL) NOPASSWD: ALL"' -- "$user"  >> '/etc/sudoers.d/mapc'

sudo ln -s /etc/nginx/sites-available/$app_name /etc/nginx/sites-enabled/$app_name
sudo service nginx restart

# Fix sudoers permissions
# sudo chown root:root /etc/sudoers.d/mapc
# sudo chmod 0440 /etc/sudoers.d/mapc

sudo usermod -a -G rvm $app_name

# Add SSH keys of each MAPC employee to each app user and add SSH key of each MAPC person to their own user account
# Add public key for user to authorized_keys
sudo su $app_name
rvm user gemsets

# Add key of each MAPC user
for user in "${mapc_users[@]}"
do
  curl -L http://bit.ly/gh-keys | bash -s $user
done

# install ruby and bundler
# rvm install $ruby_version
# rvm use $ruby_version
# gem install bundler

# enable git lfs
git lfs install

# Setup /etc/nginx/sites-available with a config file for the server

# server {
#         listen 80;
#   listen [::]:80;

#   server_name staging.masaferoutessurvey.org;

#         root /var/www/myschoolcommute2/current/public;
#         passenger_enabled on;
#         passenger_app_env staging;
#   passenger_env_var DATABASE_URL "postgis://*REMOVED*";
#   passenger_env_var TEST whatever;
#   passenger_env_var DATABASE_TEST foo_db;

#   # include snippets/ssl-dyee.mapc.org.conf;
#   # include snippets/ssl-params.conf;
# }
