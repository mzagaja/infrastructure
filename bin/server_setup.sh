Staging Server Setup - Ubuntu 16.04

# Go to aws.amazon.com and setup a new m3.medium instance in the console. Use elastic IP to attach a static IP because otherwise you get a new IP if you respawn the instance. Use EBS storage to not lose data upon a reboot.
# Pipe this into an SSH session: cat commands-to-execute-remotely.sh | ssh blah_server

# Get server name from command line argument
server_name=$1

sudo apt-get update
sudo apt-get upgrade -q -y

sudo hostnamectl set-hostname $server_name
sudo timedatectl set-timezone America/New_York

#Install phusion passenger keys
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
# Install https support for apt along with basic packages
sudo apt-get install -y libpq-dev nodejs fail2ban zsh postgresql postgresql-contrib git apt-transport-https ca-certificates

# Add Passenger APT repository and Install Passenger + Nginx
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y nginx-extras passenger

# ​Edit /etc/nginx/nginx.conf and uncomment include /etc/nginx/passenger.conf;
# sudo service nginx restart

#install GPG and RVM cert
sudo apt-get install gnupg2
gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

#install RVM
sudo apt-add-repository -y ppa:rael-gc/rvm
sudo apt-get update
sudo apt-get install -y rvm

#install git-lfs
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
sudo apt-get install -y git-lfs

#install LogEntries
sudo sh -c 'echo deb http://rep.logentries.com/ xenial main > /etc/apt/sources.list.d/logentries.list'
gpg --keyserver pgp.mit.edu --recv-keys A5270289C43C79AD && gpg -a --export A5270289C43C79AD | sudo apt-key add -
sudo apt-get update
sudo apt-get install -y python-setproctitle logentries
sudo le register --account-key=2c1f8a01-2bdd-4c2a-a2b5-360cfe78de39
sudo apt-get install -y logentries-daemon

#Need to setup logfile locations in /etc/le/config

#Allow HTTPS and WWW connections
sudo ufw allow ssh
sudo ufw allow www
sudo ufw allow https
sudo ufw enable

#Create swapfile for large repos
sudo umount /dev/xvdb
sudo mkswap /dev/xvdb
sudo swapon /dev/xvdb

# Edit fstab to mount swap automatically
# sudo vim /etc/fstab
# /dev/xvdb       none    swap    sw  0       0

## User Setup Steps for MAPC Users
mapc_users=(mzagaja ericyoungberg)

# Add users for each MAPC person with sudo access
for user in "${mapc_users[@]}"
do
  sudo adduser -q --disabled-password --shell /bin/zsh --gecos "" $user
  sudo adduser $user sudo
  sudo su $user
  # Add SSH private key from github
  curl -L http://bit.ly/gh-keys | bash -s $user
  # Setup prezto
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  setopt EXTENDED_GLOB
  for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  done
  exit
  chage -d0 $user
done

# Add to end of .zshrc
# [[ -s “$HOME/.rvm/scripts/rvm” ]] && . “$HOME/.rvm/scripts/rvm”

# Add to/modify .zpreztorc
# zstyle ':prezto:load' pmodule \
#   'environment' \
#   'terminal' \
#   'editor' \
#   'history' \
#   'directory' \
#   'spectrum' \
#   'utility' \
#   'completion' \
#   'prompt'  \
#   'history-substring-search'
