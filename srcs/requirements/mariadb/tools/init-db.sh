#!/bin/sh
set -e

DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

chown -R mysql:mysql /var/lib/mysql

#-d tests whether a folder exists, and ! means “not”.
if [ ! -d /var/lib/mysql/mysql ]; then
	#Creates the empty system databases MariaDB needs.
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

    mariadbd --user=mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
fi

exec mariadbd --user=mysql



#The if: it checks a folder in the data folder
#(/var/lib/mysql/mysql, which is the volume), not in the image.
#If the folder doesn’t exist, the database is new, so the script
#sets it up. If it exists, the setup is skipped.

#When the container starts, the script reads the passwords, creates the
#database and users only the first time, and then hands control to the
#MariaDB server.
