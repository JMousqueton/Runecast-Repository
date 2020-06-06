#!/bin/bash

#==============================================================================
#title           : createRepo.sh
#description     : Create a local repository for RuneCast Analyzer
#author	      	 : Julien Mousqueton (@JMousqueton)
#date            : 20200605
#version         : 1.0
#usage		       : bash createRepo.sh
#notes           : Check on Ubuntu.
#==============================================================================
# Variables
#==============================================================================
Root="/var/www/updates-runecast" # Change with your own path
FQDN="updates-runecast.mousqueton.io" # Change with your FQDN
SSL=false #Generate SSL Certificat
MAIL='' # Email if SSL is true (need by Let's Encrypt)

#==============================================================================
# Constant
#==============================================================================
TEMP=$(mktemp XXXXXXXXX)
#==============================================================================
# Main
#==============================================================================
# Install requirement packages
sudo apt updates
sudo apt install nginx apt-mirror -y
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


# Install cron.d file  https://github.com/JMousqueton/Runecast-Repository/blob/master/LICENSE
sudo bash -c 'cat << EOF > /etc/cron.d/runecast.cron
#
# Regular cron jobs for the apt-mirror package
#
20 3     * * *   apt-mirror      /usr/bin/apt-mirror > /var/spool/apt-mirror/var/cron.log
0 3     * * *   root            curl  https://updates.runecast.com/definitions/kbupdates.bin -o $Root/definitions/kbupdates.bin
10 3    * * *   root            curl https://updates.runecast.com/definitions/version.txt -o $Root/definitions/version.txt
00 4    * * *   root            /usr/local/bin/checkchange
EOF'

# update definition manually
mkdir $Root/definitions
sudo curl  https://updates.runecast.com/definitions/kbupdates.bin -o $Root/definitions/kbupdates.bin
sudo curl https://updates.runecast.com/definitions/version.txt -o $Root/definitions/version.txt


# Install checkchange
sudo curl https://github.com/JMousqueton/Runecast-Repository/blob/master/checkversion -o /usr/local/bin/checkchange
sudo chmod +x /usr/local/bin/checkchange

# Generate SSL Certificat if SSL is set to true
if [ $SSL ]; then
sudo certbot --nginx -d $FQDN --agree-tos -m $MAIL -n --redirect
fi
