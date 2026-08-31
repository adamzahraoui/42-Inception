#!/bin/bash
set -e

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

mysqld_safe &
until mariadb-admin ping --silent; do
    sleep 1
done

mariadb -e "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;"
mariadb -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -e "ALTER USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
mariadb -e "GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';"
mariadb -e "FLUSH PRIVILEGES;"

mysqladmin -u root shutdown
exec mysqld_safe