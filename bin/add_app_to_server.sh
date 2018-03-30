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

# Issue: Need to do this as the postgres user
createdb $app_name

# Issue: need to actually create sites-available config file from template
# See https://stackoverflow.com/a/6215113 to implement template for nginx config file.

sudo ln -s /etc/nginx/sites-available/$app_name /etc/nginx/sites-enabled/$app_name

if [[ sudo nginx -t ]]; then
    echo "nginx config ok!"
else
    exit 1
fi

sudo service nginx restart

sudo usermod -a -G rvm $app_name

# Add SSH keys of each MAPC employee to each app user and add SSH key of each MAPC person to their own user account
# Add public key for user to authorized_keys
echo 'source /usr/share/rvm/scripts/rvm' | sudo tee -a /home/$app_name/.bashrc > /dev/null
sudo su $app_name
rvm user gemsets

# Add key of each MAPC user
for user in "${mapc_users[@]}"
do
  curl -L http://bit.ly/gh-keys | bash -s $user
done

# install ruby and bundler
rvm install $ruby_version
rvm use $ruby_version
gem install bundler

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
