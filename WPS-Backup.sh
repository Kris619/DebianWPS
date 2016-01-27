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


# Take input and double check.
takeinput ()
{
    while true; do
        read -p $1 answer
        read -p "Is \"$answer\" your final answer? (Y/n)" yn

        if [ "$yn" == "Y" ]; then
            echo $answer
            break
        fi

    done
}

# Get input on MySQL database
echo "Attempting to backup MySQL database..."
echo "Please enter MySQL information below:"
user=$(takeinput "Username:")
pass=$(takeinput "Password:")
host=$(takeinput "Host:")
db=$(takeinput "Database:")

# Get current time in seconds.
time=$(date +%s)

# Backup a MySQL database
mysqldump --user=$user --password=$pass --host=$host $db > $db-$time.sql

echo "MySQL database $db has been backed up."

