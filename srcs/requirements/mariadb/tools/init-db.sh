#!/bin/sh
set -e

DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

#-R means recursive: apply the change to the folder and everything inside it
chown -R mysql:mysql /var/lib/mysql

#-d tests whether a folder exists, and ! means “not”.
#Read it as: “if the folder /var/lib/mysql/mysql doesn’t exist, do the setup.”
if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null #Creates the empty system databases MariaDB needs.

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


#When the container starts, the script reads the passwords, creates the
#database and users only the first time, and then hands control to the
#MariaDB server.
