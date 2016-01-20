#!/bin/sh

#  DebianWPS. Debian WordPress-Scripts to manage WordPress installations.
#  Copyright (C) 2016  Kris Lamoureux

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, version 3 of the License.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.


# Testing Mode features include:
# * Installing Tor hidden services (for use in a VM).
testmode=true

# Checks for an installed package
checkinstall ()
{
    if dpkg-query -W $1; then
        # true
        return 0
    fi

    # false
    return 1
}

# Check for root
if [[ $EUID -ne 0 ]]; then
    echo "Error: This script requires root privileges."
    exit 1
fi

# Install web server
apt-get update
apt-get install apache2 php5 php5-mysql mysql-server openssl

# Install Tor if Test Mode is enabled
if $testmode; then
    apt-get install tor
fi

# Install ca-certificates if it does not already exist.
if ! checkinstall ca-certificates; then
    apt-get install ca-certificates
fi

# Install WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
mv wordpress/* .
rm -r wordpress
rm latest.tar.gz

# Modify configurations
echo "extension=mysql.so" >> /etc/php5/apache2/php.ini
echo "HiddenServiceDir /var/lib/tor/hidden_service/" >> /etc/tor/torrc
echo "HiddenServicePort 80 127.0.0.1:80" >> /etc/tor/torrc
service tor restart
service apache2 restart

# Inform user on their new .onion address
if $testmode; then
    echo "Tor Hidden Service"
    cat /var/lib/tor/hidden_service/hostname
fi

# Initiate MySQL database
echo "Initiating the MySQL database..."
echo "Username: root"
mysql -uroot -p -e "CREATE DATABASE IF NOT EXISTS wordpress;"

# Move default html index file so WordPress can run
if [ -f /var/www/html/index.html ]; then
    mv /var/www/html/index.html /var/www/html/indexold.html
fi

# Temporary permissions
chmod 777 /var/www/html

read -p "Create wp-config.php before proceeding.
Press any button to continue."

# Setup safe WordPress permissions
chown www-data:www-data /var/www/html
find . -type f -exec chmod 664 {} +
find . -type d -exec chmod 775 {} +

echo "The latest WordPress has been installed"
exit 0

