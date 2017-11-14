#!/bin/bash

# Changes username, home folder, and group name for
# the specified user.

# Usage: change_username.sh $oldname $username

if [ -z $1 ] || [ -z $2 ]; then
  echo "Must supply the old username followed by the new username"
  exit 1
fi

old=$1
new=$2


sudo usermod -l $old $new
sudo usermod -d /home/$new -m $new

sudo groupmod --new-name $new $old

exit 0
