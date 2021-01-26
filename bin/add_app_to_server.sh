#!/bin/bash
# bin/add_app_to_server.sh $app_name $ruby_version $app_url

mapc_users=(mzagaja atomtay)
app_name=$1
ruby_version=$2
app_url=$3

## User Setup for Deploy Users
sudo adduser -q --disabled-password --gecos "" $app_name
sudo mkdir -p /var/www/$app_name/shared/config

# Edit the database configuration file
# nano /var/www/$app_name/shared/config/database.yml
read -s -p "Please update /var/www/$app_name/shared/config/database.yml and then hit enter to continue."

sudo chown -R $app_name:$app_name /var/www/$app_name

# sudo chmod 600 /var/www/$app_name/shared/config/database.yml

# Create database if on staging. For production need to do this manually.
if hostname === 'prep-mapc-org'; then
  sudo -u postgres createuser -d $app_name
  sudo -u postgres createdb -O $app_name $app_name
fi

sudo wget -O /etc/nginx/sites-available/$app_url https://raw.githubusercontent.com/MAPC/infrastructure/master/conf/nginx/site-config.template

read -s -p "Please update nginx configurtion to /etc/nginx/sites-available/$app_url and then hit enter to continue."

# TODO: Need to seed database after the deploy
# TODO: Add pg_hba.conf update for the app on pg.mapc.org, or just enable all
# connections to pg.mapc.org from live.mapc.org

# Issue: need to actually create sites-available config file from template
# See https://stackoverflow.com/a/6215113 to implement template for nginx config file.

sudo ln -s /etc/nginx/sites-available/$app_url /etc/nginx/sites-enabled/$app_url

if [[ sudo nginx -t ]]; then
   echo "nginx config ok!"
else
    exit 1
fi

sudo certbot -n --nginx -d $app_url

sudo service nginx restart

sudo usermod -a -G rvm $app_name

# Add SSH keys of each MAPC employee to each app user and add SSH key of each MAPC person to their own user account
# Add public key for user to authorized_keys
echo 'source /usr/share/rvm/scripts/rvm' | sudo tee -a /home/$app_name/.bashrc > /dev/null
sudo su - $app_name
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

# add nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
nvm install node
nvm alias default node
