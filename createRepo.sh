#!/bin/bash

#==============================================================================
#title           : createRepo.sh
#description     : Create a local repository for RuneCast Analyzer
#author	      	 : Julien Mousqueton (@JMousqueton)
#date            : 20200605
#version         : 3.0
#usage		       : bash createRepo.sh
#notes           : Checked on Ubuntu.
#==============================================================================
# Variables
#==============================================================================
SSL=false #Generate SSL Certificat
ConfFile="/etc/RunecastUpdate.conf"

declare Root
declare To

if [ -f "$ConfFile" ]; then
# shellcheck source=RunecastUpdate.conf
   source "$ConfFile"
   else
   echo "Error: No configuration present"
   exit 1;
fi

regex="^([A-Za-z]+[A-Za-z0-9]*\+?((\.|\-|\_)?[A-Za-z]+[A-Za-z0-9]*)*)@(([A-Za-z0-9]+)+((\.|\-|\_)?([A-Za-z0-9]+)+)*)+\.([A-Za-z]{2,})+$"

if [ -z "$Root" ]; then
  echo "Error: Root parameter must be set"
  exit 1;
else
  if [ ! -d "$Root" ]; then
    echo "Error: $Root must exist"
  fi
fi

if [ $SSL ]; then
  if [ -z "$To" ]; then
      echo "Error: To parameter must be configured"
      exit 1;
   else
   if [[ ! $To =~ ${regex} ]]; then
      echo "Error: To must be a valid email"
      exit 1;
   fi
 fi
fi

#==============================================================================
# Constant
#==============================================================================
TEMP=$(mktemp -u XXXXXXXXX)
#==============================================================================
# Main
#==============================================================================
# Install requirement packages
sudo apt updates
sudo apt install nginx mailutils apt-mirror -y
if [ $SSL ]; then
  sudo apt install certbot -y
fi

#Create a backup copy of mirror.list
sudo mv /etc/apt/mirror.list "/etc/apt/mirror.list.$TEMP"

# Create a new mirror.list file
sudo bash -c 'cat << EOF > /etc/apt/mirror.list
############# config ##################
#
set base_path    /var/spool/apt-mirror
#
# set mirror_path  \$base_path/mirror
# set skel_path    \$base_path/skel
# set var_path     \$base_path/var
# set cleanscript \$var_path/clean.sh
# set defaultarch  <running host architecture>
# set postmirror_script \$var_path/postmirror.sh
set run_postmirror 0
set nthreads     20
set _tilde 0
#
############# end config ##############

deb https://updates.runecast.com/runecast-analyzer-vmware /
clean https://updates.runecast.com/runecast-analyzer-vmware
EOF'


#Create Repo Directory
mkdir -p $Root/definitions

# Run a manual Sync
sudo -u apt-mirror apt-mirror

# Create symbolic link
sudo ln -s  /var/spool/apt-mirror/mirror/updates.runecast.com/ $Root

# Create a temp nginx file (necessary to easily pass variables)
cat << EOF > /tmp/runecast.conf.$TEMP
server {
  server_name $FQDN;

  root $Root;
  autoindex off;
  autoindex_format html;

 access_log /var/log/nginx/runecast-access.log combined;
 error_log  /var/log/nginx/runecast-error.log;

 listen *:80;
}
EOF
# Move temp file to destination
sudo mv /tmp/runecast.conf.$TEMP /etc/nginx/sites-available/runecast.conf

# activate the vhost
sudo ln -s /etc/nginx/sites-available/runecast.conf /etc/nginx/sites-enabled/

# Restart nginx
sudo systemctl restart nginx


# Install cron.d file  
sudo bash -c 'cat << EOF > /etc/cron.d/runecast.cron
#
# Regular cron jobs for RunecastUpdate
#
00 4    * * *   root            /usr/local/bin/RunecastUpdate
EOF'

# update definition manually
sudo curl https://raw.githubusercontent.com/JMousqueton/Runecast-Repository/master/RunecastUpdate -o /usr/local/bin/RunecastUpdate
sudo chmod +x /usr/local/bin/RunecastUpdate
sudo RunecastUpdate

# Generate SSL Certificat if SSL is set to true
if [ $SSL ]; then
sudo certbot --nginx -d $FQDN --agree-tos -m $To -n --redirect
fi
