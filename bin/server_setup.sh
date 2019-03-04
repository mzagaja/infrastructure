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
sudo apt-get install -y libpq-dev nodejs fail2ban postgresql postgresql-contrib git apt-transport-https ca-certificates vim

# Add Passenger APT repository and Install Passenger + Nginx
sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
sudo apt-get update
sudo apt-get install -y nginx-extras passenger

# Edit /etc/nginx/nginx.conf and uncomment include /etc/nginx/passenger.conf;
# sudo service nginx restart
# Add certbot to crontab
# 48 6 * * * certbot renew --post-hook "systemctl reload nginx”

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

# Install AWS CloudWatch Client
# In EC2 console attach to CloudWatchAgentServerRole via Actions --> Instance Settings --> Attach/Replace IAM Role
mkdir cloudwatch-agent
cd cloudwatch-agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/linux/amd64/latest/AmazonCloudWatchAgent.zip
unzip AmazonCloudWatchAgent.zip

# TODO: Automate install/setup of this.
# sudo ./install.sh
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
# sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

# Some EC2 instances come with an included volume. In this case we use it to create swapfile for large repos
# sudo umount /dev/xvdb
# sudo mkswap /dev/xvdb
# sudo swapon /dev/xvdb

# Edit fstab to mount swap automatically
# sudo vim /etc/fstab
# /dev/xvdb       none    swap    sw  0       0

## User Setup Steps for MAPC Users
mapc_users=(mzagaja ericyoungberg smithwebtek)

# Add users for each MAPC person with sudo access
for user in "${mapc_users[@]}"
do
  sudo adduser -q --gecos "" $user
  sudo usermod -a -G sudo $user
  echo -e "mapc\nmapc" | sudo passwd -e $user
  sudo su $user
  # Add SSH private key from github
  curl -L http://bit.ly/gh-keys | bash -s $user
  exit
done

# Add to end of .bashrc if necessary
# [[ -s “$HOME/.rvm/scripts/rvm” ]] && . “$HOME/.rvm/scripts/rvm”
